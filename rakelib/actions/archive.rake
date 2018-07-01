# General purpose archive helpers (zip or tarball installs)
module Archive
  module_function

  # install downloads specified archive and extracts it then uses manifest file to
  # copy files to <dest>/<key>. By default, `/usr/local` will be used.
  #
  # manifest:
  #   {
  #     bin: ['cmd1', 'rel/path/cmd2', 'bin/*']
  #     lib: ['lib1', 'rel/path/lib2', 'lib/*']
  #     man: ['man1', 'rel/path/man2', 'man/*']
  #   }
  def install(manifest, url, dest: '/usr/local', headers: {}, sig: {})
    Bootstrap::Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
      dirpath = Pathname.new(d)
      manifest.each do |key, patterns|
        patterns.each do |pattern|
          sources = Dir.glob(File.join(d, pattern))
          sources.each do |source|
            sourcepath = Pathname.new(source)
            relsource = sourcepath.relative_path_from(dirpath)
            target = File.join(dest, sourcepath.fnmatch?("#{key}/**") ? File.join(key, relsource) : relsource)
            sig = sourcepath.sub_ext('.sig')
            Bootstrap.gpg_sig(source, sig) if File.exist?(sig)
            Bootstrap.sudo_mkdir File.dirname(target)
            Bootstrap.sudo_cp source, target
          end
        end
      end
    end
  end

  # uninstall removes sources from <dest>/<key>
  # By default, `/usr/local` is dest
  # uses same manifest as install
  def uninstall(manifest, dest: '/usr/local')
    manifest.each do |key, patterns|
      patterns.each do |pattern|
        glob = pattern.start_with?("#{key}/") ? pattern : File.join(key, pattern)
        targets = Dir.glob(File.join(dest, glob))
        targets.each do |t|
          if Dir.exist?(t)
            Bootstrap.sudo_rmdir(t) if Bootstrap.dir_empty?(t)
          else
            Bootstrap.sudo_rm t
          end
        end
      end
    end
    Bootstrap.dir_prune(dest)
  end
end

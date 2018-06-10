module Bootstrap
  # General purpose archive helpers (zip or tarball installs)
  module Archive
    # install downloads specified archive and extracts it then uses manifest file to
    # copy files to /usr/local/<key>
    #
    # manifest:
    #   {
    #     bin: ['cmd1', 'rel/path/cmd2', 'bin/*']
    #     lib: ['lib1', 'rel/path/lib2', 'lib/*']
    #     man: ['man1', 'rel/path/man2', 'man/*']
    #   }
    def install(manifest, url, headers: {}, sig: {})
      Bootstrap::Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
        manifest.each do |key, patterns|
          patterns.each do |pattern|
            sources = Dir.glob(File.join(d, pattern))
            sources.each do |source|
              sig = File.join(d, "#{File.basename(source, ".*")}.sig")
              Bootstrap.gpg_sig(source, sig) if File.exist?(sig)
              Bootstrap.usr_cp(source, key)
            end
          end
        end
      end
    end
    module_function :install

    # uninstall removes sources from /usr/local/<key>
    # uses same manifest as install
    def uninstall(manifest)
      manifest.each do |key, patterns|
        patterns.each do |pattern|
          targets = Bootstrap.usr_ls(pattern, key)
          targets.each { |t| Bootstrap.sudo_rm t }
        end
      end
    end
    module_function :uninstall
  end
end

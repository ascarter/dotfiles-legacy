module Bootstrap
  # General purpose archive helpers (zip or tarball installs)
  module Archive
    # install downloads specified archive and extracts it then uses manifest file to
    # copy files to /usr/local/<key>
    #
    # manifest:
    #   {
    #     bin: ['cmd1', 'rel/path/cmd2']
    #     lib: ['lib1', 'rel/path/lib2']
    #     man: ['man1', 'rel/path/man2']
    #   }
    def install(manifest, url, headers: {}, sig: {})
      Bootstrap::Downloader.download_with_extract(url, headers: headers, sig: sig) do |d|
        manifest.each do |key, sources|
          sources.each do |s|
            source = File.join(d, s)
            signature = File.join(d, "#{s}.sig")
            if File.exist?(signature)
              Bootstrap.gpg_sig(source, signature)
            end
            Bootstrap.usr_cp(source, key)
          end
        end
      end
    end
    module_function :install

    # uninstall removes sources from /usr/local/<key>
    # uses same manifest as install
    def uninstall(manifest)
      manifest.each do |key, sources|
        sources.each { |s| Bootstrap.usr_rm(s, key) }
      end
    end
    module_function :uninstall
  end
end

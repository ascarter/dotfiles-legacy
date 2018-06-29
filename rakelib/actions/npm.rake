module Actions
  module NPM
    # npm install -g <pkgs>
    def install(args)
      args.each { |pkg| Bootstrap::NPM.install pkg }
    end
    module_function :install

    # npm uninstall -g <pkgs>
    def uninstall(args)
      args.each { |pkg| Bootstrap::NPM.uninstall pkg }
    end
    module_function :uninstall
  end
end

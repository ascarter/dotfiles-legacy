module Bootstrap
  # git helpers
  module Git
    # git configuration
    module Config
      def get(key)
        `git config --global --get #{key}`.strip
      end
      module_function :get

      def set(key, value)
        system %(git config --global #{key} "#{value}")
      end
      module_function :set

      def unset(key)
        system %(git config --global --unset #{key})
      end
      module_function :unset
    end

    def clone(repo, dest = nil)
      git_url = URI.join('https://github.com/', "#{repo}.git").to_s
      system %(git clone #{git_url} #{dest ? dest.to_s : ''})
    end
    module_function :clone

    def fetch(path)
      system "cd #{path} && git fetch origin"
    end
    module_function :fetch

    def pull(path)
      system "cd #{path} && git pull" if File.directory?(path)
    end
    module_function :pull

    def checkout(path, tag)
      puts "checking out #{tag}"
      system "cd #{path} && git checkout -q #{tag}" if File.directory?(path)
    end
    module_function :checkout

    def latest_tag(path, filter = nil)
      args = %w(--abbrev=0 --tags)
      args << %(--match "#{filter}")
      `cd #{path} && git describe #{args.join(" ")} origin`
    end
    module_function :latest_tag
  end
end

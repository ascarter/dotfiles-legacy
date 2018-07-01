module Bootstrap
  # git helpers
  module Git
    module_function

    # git configuration
    module Config
      module_function

      def get(key)
        `git config --global --get #{key}`.strip
      end

      def set(key, value)
        system %(git config --global #{key} "#{value}")
      end

      def unset(key)
        system %(git config --global --unset #{key})
      end
    end

    def clone(repo, dest = nil)
      git_url = URI.join('https://github.com/', "#{repo}.git").to_s
      system %(git clone #{git_url} #{dest ? dest.to_s : ''})
    end

    def fetch(path)
      system "cd #{path} && git fetch origin"
    end

    def pull(path)
      system "cd #{path} && git pull" if File.directory?(path)
    end

    def checkout(path, tag)
      puts "checking out #{tag}"
      system "cd #{path} && git checkout -q #{tag}" if File.directory?(path)
    end

    def latest_tag(path, filter = nil)
      args = %w(--abbrev=0 --tags)
      args << %(--match "#{filter}")
      `cd #{path} && git describe #{args.join(" ")} origin`
    end
  end
end

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

    def pull(path)
      system "cd #{path} && git pull" if File.directory?(path)
    end
    module_function :pull
  end
end

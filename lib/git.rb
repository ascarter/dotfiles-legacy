#
# git helpers
#

module Bootstrap
  module Git
    module Config
      def get(key)
        return %x{git config --global --get #{key}}.strip
      end
      module_function :get
      
      def set(key, value)
        system %Q{git config --global #{key} "#{value}"}
      end
      module_function :set
    end
  
    def clone(repo, dest=nil)
      git_url = URI.join("https://github.com/", "#{repo}.git").to_s
      system %Q{git clone #{git_url} #{dest ? dest.to_s : ''}}
    end
    module_function :clone

    def pull(path)
      if File.directory?(path)
        system "cd #{path} && git pull"
      end
    end
    module_function :pull
  end
end

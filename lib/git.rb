#
# git helpers
#

module Bootstrap
  module Git
    def config(key, value)
      system "git config --global #{key} \"#{value}\""
    end
    module_function :config
  
    def clone(repo, dest=nil)
      git_url = URI.join("https://github.com/", "#{repo}.git").to_s
      system "git clone #{git_url} #{dest ? dest.to_s : ''}"
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

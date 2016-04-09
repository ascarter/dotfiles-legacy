# CodeRunner

namespace "coderunner" do 
  desc "Install CodeRunner"
  task :intstall do
    if RUBY_PLATFORM =~ /darwin/
      unless app_exists("CodeRunner")
        pkg_url = 'https://coderunnerapp.com/download'
        pkg_download(pkg_url) do |p|
          unzip(p)
          app_install(File.join(File.dirname(p), "CodeRunner.app"))
        end
      end
    else
      raise "Platform not supported"
    end
  end
    
  desc "Uninstall CodeRunner"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      app_remove("CodeRunner")
    end
  end
end

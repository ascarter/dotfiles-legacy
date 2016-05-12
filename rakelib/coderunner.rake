# CodeRunner

if Bootstrap.macosx?
  CODERUNNER_APP_NAME = 'CodeRunner'
  CODERUNNER_SOURCE_URL = 'https://coderunnerapp.com/download'
  
  namespace "coderunner" do 
    desc "Install CodeRunner"
    task :intstall do
      Bootstrap::MacOSX::App.install(CODERUNNER_APP_NAME, CODERUNNER_SOURCE_URL)
    end
    
    desc "Uninstall CodeRunner"
    task :uninstall do
      Bootstrap::MacOSX::App.uninstall(CODERUNNER_APP_NAME)
    end
  end
end
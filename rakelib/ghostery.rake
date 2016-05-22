# Ghostery tasks

GHOSTERY_SAFARI_EXTENSION = 'Ghostery'
GHOSTERY_SOURCE_URL = 'https://www.ghostery.com/safari/Ghostery.safariextz'

namespace 'ghostery' do
  desc 'Install Ghostery'
  task :install do
    case RUBY_PLATFORM
    when /darwin/ 
      Bootstrap::MacOSX::SafariExtension.install(GHOSTERY_SAFARI_EXTENSION, GHOSTERY_SOURCE_URL)
    end
  end
  
  desc 'Uninstall Ghostery'
  task :uninstall do
  end
end

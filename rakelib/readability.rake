# Readability tasks

READABILITY_SAFARI_EXTENSION = 'readability-1.10'
READABILITY_SOURCE_URL = 'https://www.readability.com/extension/safari'

namespace 'readability' do
  desc 'Install Readbility'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::SafariExtension.install(READABILITY_SAFARI_EXTENSION, READABILITY_SOURCE_URL)
    end
  end
  
  desc 'Uninstall Readability'
  task :uninstall do
  end
end

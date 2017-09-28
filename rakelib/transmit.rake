# transmit tasks

TRANSMIT_APP_NAME = 'Transmit'.freeze
TRANSMIT_SOURCE_URL = 'https://download.panic.com/transmit/Transmit%205.0.3.zip'.freeze

namespace 'transmit' do
  desc 'Install transmit'
  task :install do
    Bootstrap::MacOSX::App.install(TRANSMIT_APP_NAME, TRANSMIT_SOURCE_URL)
  end

  desc 'Uninstall transmit'
  task :uninstall do
    Bootstrap::MacOSX::App.uninstall(TRANSMIT_APP_NAME)
  end
end

# coda tasks

CODA_APP_NAME = 'Coda 2'.freeze
CODA_SOURCE_URL = 'http://download.panic.com/coda/Coda%202.5.16.zip'.freeze

namespace 'coda' do
  desc 'Install coda'
  task :install do
    Bootstrap::MacOSX::App.install(CODA_APP_NAME, CODA_SOURCE_URL)
  end

  desc 'Uninstall coda'
  task :uninstall do
    Bootstrap::MacOSX::App.uninstall(CODA_APP_NAME)
  end
end

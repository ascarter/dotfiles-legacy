# manopen tasks

MANOPEN_APP_NAME = 'ManOpen'
MANOPEN_SOURCE_URL = 'http://www.clindberg.org/projects/ManOpen-2.6.dmg'

if Bootstrap.macosx?
  namespace 'manopen' do
    desc 'Install manopen'
    task :install do
      Bootstrap::MacOSX::App.install(MANOPEN_APP_NAME, MANOPEN_SOURCE_URL,
        cmdfiles: ['openman'], manfiles: ['openman.1'])      
    end
  
    desc 'Uninstall manopen'
    task :uninstall do
      Bootstrap::MacOSX::App.uninstall(MANOPEN_APP_NAME)
      Bootstrap.usr_bin_rm('openman')
      Bootstrap.usr_man_rm('openman.1')
    end	
  end
end

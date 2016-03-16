# Macports tasks

namespace "macports" do
  desc "Install macports"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      puts "Installing macports..."
      macports_root = '/opt/local'
      macports_url = 'https://distfiles.macports.org/MacPorts'
      macports_pkg = 'MacPorts-2.2.0-10.8-MountainLion.pkg'
      unless File.exist?(macports_root)
        system "curl -L #{macports_url}/#{macports_pkg} -o /tmp/#{macports_pkg}"
        sudo "installer -pkg /tmp/#{macports_pkg} -target /"
        file_remove("/tmp/{macports_pkg}")
      end
      path_helper('macports', ['/opt/local/bin', '/opt/local/sbin'])
      path_helper('macports', ['/opt/local/share/man'], 'manpaths')
      sudo "/opt/local/bin/port -v selfupdate"
    else
      puts "Macports not supported on #{RUBY_PLATFORM}"
    end
  end

  desc "Uninstall macports"
  task :uninstall do
    puts "Uninstall macports..."
    macports_root = '/opt/local'
    installed_files = [
      '/opt/local',
      '/Applications/DarwinPorts',
      '/Applications/MacPorts',
      '/Library/LaunchDaemons/org.macports.*',
      '/Library/Receipts/DarwinPorts*.pkg',
      '/Library/Receipts/MacPorts*.pkg',
      '/Library/StartupItems/DarwinPortsStartup',
      '/Library/Tcl/darwinports1.0',
      '/Library/Tcl/macports1.0',
      '~/.macports',
      '/etc/paths.d/macports',
      '/etc/manpaths.d/macports'
    ]
    sudo "port -fp uninstall installed"
    sudo "rm -rf #{installed_files.join(' ')}"
  end

  desc "Add svn source"
  task :svn_source do
    macports_root = '/opt/local'
    macports_svn_root = "#{macports_root}/sources/svn.macports.org/trunk/dports"
    macports_svn_url = 'http://svn.macports.org/repository/macports/trunk/dports/'
    sudo "mkdir -p #{macports_svn_root}"
    sudo "cd #{macports_svn_root} && svn co #{macports_svn_url} ."
    sudo "echo 'file:///opt/local/var/macports/sources/svn.macports.org/trunk/dports/' > #{macports_root}/etc/macports/sources.conf"
    sudo "port -d sync"
  end
end

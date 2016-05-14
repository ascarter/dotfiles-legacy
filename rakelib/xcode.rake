# Xcode tasks

if Bootstrap.macosx?
  namespace 'xcode' do
    desc 'Install Xcode command line tools'
    task :install do
      Bootstrap.sudo 'xcode-select --install'
    end
  
    desc 'Install Xcode themes'
    task :themes do
      src = File.join(File.dirname(__FILE__), '../xcode/themes')
      dest = File.expand_path(File.join(Bootstrap.home_dir, 'Library/Developer/Xcode/UserData/FontAndColorThemes/'))
      FileUtils.mkdir_p(dest)
      FileUtils.cp(Dir.glob(File.join(src, '*.dvtcolortheme')), dest)
    end

    desc 'Uninstall Xcode command line tools'
    task :uninstall do
      # TODO: Uninstall Xcode command line tools
      warn 'Not yet implemented'
    end

    desc 'Reset Xcode preferences'
    task :reset do
      Bootstrap::MacOSX::Defaults.delete 'com.apple.dt.Xcode'
    end
  end
end

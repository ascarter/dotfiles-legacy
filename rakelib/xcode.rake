# Xcode tasks

if Bootstrap.macosx?
  namespace 'xcode' do
    desc 'Install Xcode command line tools'
    task :install do
      Bootstrap.sudo 'xcode-select --install'
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

    namespace 'themes' do
      desc 'Install Xcode themes'
      task :install do
        srcdir = File.expand_path(File.join(File.dirname(__FILE__), '../themes/xcode'))
        dest = File.expand_path(File.join(Bootstrap.library_dir, 'Developer', 'Xcode', 'UserData', 'FontAndColorThemes'))
        FileUtils.mkdir_p(dest)
        Dir.glob(File.join(srcdir, '*.xccolortheme')).each do |f|
          target = File.join(dest, File.basename(f))
          Bootstrap.link_file(f, target)
        end
      end
      
      desc 'Uninstall Xcode themes'
      task :uninstall do
        srcdir = File.expand_path(File.join(File.dirname(__FILE__), '../themes/xcode'))
        dest = File.expand_path(File.join(Bootstrap.library_dir, 'Developer', 'Xcode', 'UserData', 'FontAndColorThemes'))
        Dir.glob(File.join(srcdir, '*.xccolortheme')).each do |f|
          target = File.join(dest, File.basename(f))
          Bootstrap.file_remove(target)
        end
      end
    end
  end
end

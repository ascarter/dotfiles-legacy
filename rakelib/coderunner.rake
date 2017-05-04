# CodeRunner

CODERUNNER_APP_NAME = 'CodeRunner'.freeze
CODERUNNER_SOURCE_URL = 'https://coderunnerapp.com/download'.freeze

if Bootstrap.macosx?
  namespace 'coderunner' do
    desc 'Install CodeRunner'
    task :install do
      Bootstrap::MacOSX::App.install(CODERUNNER_APP_NAME, CODERUNNER_SOURCE_URL)
    end

    desc 'Uninstall CodeRunner'
    task :uninstall do
      Bootstrap::MacOSX::App.uninstall(CODERUNNER_APP_NAME)
    end
    
    namespace 'themes' do
      desc 'Install CodeRunner themes'
      task :install do
        srcdir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'themes', 'coderunner'))
        dest = File.expand_path(File.join(Bootstrap.library_dir, 'Application Support', 'CodeRunner', 'Themes'))
        FileUtils.mkdir_p(dest)
        Dir.glob(File.join(srcdir, '*.tmTheme')).each do |f|
          target = File.join(dest, File.basename(f))
          Bootstrap.link_file(f, target)
        end
      end
      
      desc 'Uninstall Xcode themes'
      task :uninstall do
        srcdir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'themes', 'coderunner'))
        dest = File.expand_path(File.join(Bootstrap.library_dir, 'Application Support', 'CodeRunner', 'Themes'))
        Dir.glob(File.join(srcdir, '*.tmTheme')).each do |f|
          target = File.join(dest, File.basename(f))
          Bootstrap.file_remove(target)
        end
      end
    end
  end
end

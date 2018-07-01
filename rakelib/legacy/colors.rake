# macOS Colors

if Bootstrap.macOS?
  namespace 'colors' do
    namespace 'palettes' do
      desc 'Install color palettes'
      task :install do
        srcdir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'themes', 'palettes', 'macos'))
        dest = File.expand_path(File.join(Bootstrap.library_dir, 'Colors'))
        FileUtils.mkdir_p(dest)
        Dir.glob(File.join(srcdir, '*.clr')).each do |f|
          target = File.join(dest, File.basename(f))
          Bootstrap.link_file(f, target)
        end
      end

      desc 'Uninstall color palettes'
      task :uninstall do
        srcdir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'themes', 'palettes', 'macos'))
        dest = File.expand_path(File.join(Bootstrap.library_dir, 'Colors'))
        Dir.glob(File.join(srcdir, '*.clr')).each do |f|
          target = File.join(dest, File.basename(f))
          Bootstrap.file_remove(target)
        end
      end
    end

    namespace 'colorpicker' do
      desc 'Install color pickers'
      task install: ['colorpicker:developer:install', 'colorpicker:skala:install']

      desc 'Uninstall color pickers'
      task uninstall: ['colorpicker:developer:uninstall', 'colorpicker:skala:uninstall']

      namespace 'developer' do
        desc 'Install Developer Color Picker by Panic'
        task :install do
          picker = 'Developer Color Picker/DeveloperColorPicker'
          src_url = 'http://download.panic.com/picker/developercolorpicker.zip'
          MacOS::ColorPicker.install(picker, src_url)
        end

        desc 'Uninstall Developer Color Picker by Panic'
        task :uninstall do
          MacOS::ColorPicker.uninstall('DeveloperColorPicker')
        end
      end

      namespace 'skala' do
        desc 'Install Skala'
        task :install do
          picker = 'Skala Color Installer.app/Contents/Resources/SkalaColor'
          src_url = 'http://download.bjango.com/skalacolor/'
          MacOS::ColorPicker.install(picker, src_url)
        end

        desc 'Uninstall Skala'
        task :uninstall do
          MacOS::ColorPicker.uninstall('SkalaColor')
        end
      end
    end
  end
end

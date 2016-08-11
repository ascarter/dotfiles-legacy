# Color pickers

if Bootstrap.macosx?
  namespace 'colorpicker' do
    desc 'Install color pickers'
    task install: ['developer:install', 'skala:install']

    desc 'Uninstall color pickers'
    task uninstall: ['developer:uninstall', 'skala:uninstall']

    namespace 'developer' do
      desc 'Install Developer Color Picker by Panic'
      task :install do
        picker = 'Developer Color Picker/DeveloperColorPicker'
        src_url = 'http://download.panic.com/picker/developercolorpicker.zip'
        Bootstrap::MacOSX::ColorPicker.install(picker, src_url)
      end

      desc 'Uninstall Developer Color Picker by Panic'
      task :uninstall do
        Bootstrap::MacOSX::ColorPicker.uninstall('DeveloperColorPicker')
      end
    end

    namespace 'skala' do
      desc 'Install Skala'
      task :install do
        picker = 'Skala Color Installer.app/Contents/Resources/SkalaColor'
        src_url = 'http://download.bjango.com/skalacolor/'
        Bootstrap::MacOSX::ColorPicker.install(picker, src_url)
      end

      desc 'Uninstall Skala'
      task :uninstall do
        Bootstrap::MacOSX::ColorPicker.uninstall('SkalaColor')
      end
    end
  end
end

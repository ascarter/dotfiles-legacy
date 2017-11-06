# Fuji tasks

FUJI_PCAUTOSAVE_APP_NAME = 'PCAutoSaveInstaller'.freeze
FUJI_PCAUTOSAVE_UNINSTALL_APP_NAME = 'FUJIFILM PC AutoSave/PCAutoSaveUninstall'.freeze
FUJI_PCAUTOSAVE_SOURCE_URL = 'http://download.fujifilm.co.jp/pub/tools/pc_autosave_mac1010_nzjl2sai/PCAutoSaveSetup.dmg'.freeze

FUJI_XACQUIRE_APP_NAME = 'FUJIFILM X Acquire'.freeze
FUJI_XACQUIRE_SOURCE_URL = 'http://download.fujifilm.co.jp/pub/tools/x_acquire_mac16_rjdhkxt1/XAcquireIns16.dmg'.freeze

namespace 'fuji' do
  namespace 'pcautosave' do
    desc 'Install Fuji PC AutoSave'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.run(FUJI_PCAUTOSAVE_APP_NAME, FUJI_PCAUTOSAVE_SOURCE_URL)
      end
    end

    desc 'Uninstall Fuji PC AutoSave'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::run_app(FUJI_PCAUTOSAVE_UNINSTALL_APP_NAME, wait: true)
      end
    end
  end

  namespace 'xacquire' do
    desc 'Install Fuji X Acquire'
    task :instal do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.install(FUJI_XACQUIRE_APP_NAME, FUJI_XACQUIRE_SOURCE_URL)
      end
    end

    desc 'Uninstall Fuji X Acquire'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::App.uninstall(FUJI_XACQUIRE_APP_NAME)
      end
    end
  end
end

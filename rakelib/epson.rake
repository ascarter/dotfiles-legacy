# Epson tools

namespace 'epson' do
  EPSON_PKG_IDS = [
    'com.epson.pkg.ijpdrv.remoteprint.w.Machine_104_and_later',
    'com.epson.pkg.ijpdrv.remoteprint.w.Machine_105_and_later',
    'com.epson.pkg.ijpdrv.remoteprint.w.Module_107_and_later'
  ].freeze

  namespace 'remote' do
    desc 'Install Epson Remote Printer'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::Pkg.install('Epson Printer', EPSON_PKG_IDS[0], 'http://support.epson.net/rpdriver/mac/')
      end
    end

    desc 'Uninstall Epson Remote Printer'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        EPSON_PKG_IDS.each { |p| Bootstrap::MacOSX::Pkg.uninstall(p) }
      end
    end
  end
end

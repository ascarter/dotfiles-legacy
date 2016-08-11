# Viscosity

if Bootstrap.macosx?
  namespace 'viscosity' do
    VISCOSITY_APP = 'Viscosity'.freeze
    VISCOSITY_SOURCE_URL = 'https://www.sparklabs.com/downloads/Viscosity.dmg'.freeze

    desc 'Install Viscosity'
    task :install do
      Bootstrap::MacOSX::App.install(VISCOSITY_APP, VISCOSITY_SOURCE_URL)
    end

    desc 'Uninstall Viscosity'
    task :uninstall do
      Bootstrap::MacOSX::App.uninstall(VISCOSITY_APP)
    end
  end
end

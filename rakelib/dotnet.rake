# Microsoft .NET Core

DOTNET_PKG_NAME = 'dotnet-dev-osx-x64.1.0.0-preview2-003121'
DOTNET_PKG_IDS = [
  'com.microsoft.dotnet.dev.1.0.0-preview2-003121.component.osx.x64',
  'com.microsoft.dotnet.hostfxr.component.osx.x64',
  'com.microsoft.dotnet.sharedframework.Microsoft.NETCore.App.1.0.0.component.osx.x64',
  'com.microsoft.dotnet.sharedhost.component.osx.x64'
]
DOTNET_SOURCE_URL = 'https://go.microsoft.com/fwlink/?LinkID=809124'

namespace 'dotnet' do
  desc 'Install dotnet'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(DOTNET_PKG_NAME, DOTNET_PKG_IDS[0], DOTNET_SOURCE_URL)
    end
  end

  desc 'Uninstall dotnet'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      DOTNET_PKG_IDS.each { |p| Bootstrap::MacOSX::App.uninstall(p) }
    end
  end
end

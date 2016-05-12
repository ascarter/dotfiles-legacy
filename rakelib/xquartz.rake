# XQuartz X11 for Mac OS X

if Bootstrap.macosx?
  XQUARTZ_PKG_NAME = 'XQuartz'
  XQUARTZ_PKG_ID = 'org.macosforge.xquartz.pkg'
  XQUARTZ_SOURCE_URL = 'https://dl.bintray.com/xquartz/downloads/XQuartz-2.7.8.dmg'
  
  namespace "xquartz" do
    desc "Install XQuartz X11"
    task :install do
      Bootstrap::MacOSX::Pkg.install(XQUARTZ_PKG_NAME, XQUARTZ_PKG_ID, XQUARTZ_SOURCE_URL)    
    end
  
    desc "Uninstall XQuartz X11"
    task :uninstall do
      Bootstrap::MacOSX::Pkg.uninstall(XQUARTZ_PKG_ID)
    end
  end
end

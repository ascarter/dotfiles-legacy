# hdhomerun tasks

HDHOMERUN_PKG_NAME = "HDHomeRun Utilities"
HDHOMERUN_PKG_IDS = [
  "com.silicondust.hdhomerun.config.gui",
  "com.silicondust.hdhomerun_view",
  "com.silicondust.libhdhomerun"
]
HDHOMERUN_SOURCE_URL = "http://download.silicondust.com/hdhomerun/hdhomerun_mac.dmg"

namespace "hdhomerun" do
  desc "Install hdhomerun"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(HDHOMERUN_PKG_NAME, HDHOMERUN_PKG_IDS[0], HDHOMERUN_SOURCE_URL)
    end
  end

  desc "Uninstall hdhomerun"
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      HDHOMERUN_PKG_IDS.each { |p|  Bootstrap::MacOSX::Pkg.uninstall(p) }
    end
  end
end

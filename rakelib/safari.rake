# Safari tasks

namespace "safari" do
  desc "Install Safari Developer Preview"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      unless app_exists("Safari Technology Preview")
        pkg = "Safari Technology Preview for OS X El Capitan.pkg"
        pkg_url = "http://appldnld.apple.com/STP/SafariTechnologyPreview.dmg"
        pkg_download(pkg_url) do |p|
          dmg_mount(p) { |d| pkg_install(File.join(d, pkg)) }
        end
      end
    else
      raise "Platform not supported"
    end      
  end
  
  desc "Uninstall Safari Developer Preview"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      if app_exists("Safari Technology Preview")
        app_remove("Safari Technology Preview")
        # pkg_uninstall("com.apple.pkg.SafariTechPreviewElCapitan")
      end
    else
      raise "Platform not supported"
    end
  end
end

namespace "x11" do
  desc "Install X11"
  task :install do
    xquartz_root = 'http://xquartz.macosforge.org/downloads/SL'
    release = '2.7.7'
    dmg = "XQuartz-#{release}.dmg"
    dmg_url = "#{xquartz_root}/#{dmg}"
    pkg_download(dmg_url) do |p|
      src = dmg_mount(p)
      pkg_install(File.join(src, "XQuartz.pkg"))
      dmg_unmount(src)
    end
    
  end
  
  desc "Uninstall X11"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      if File.exist?('/opt/X11/bin/Xorg')
        pkg_id = "org.macosforge.xquartz.pkg"
        pkg_uninstall(pkg_id)
      else
        puts "XQuartz X11 is not installed"
      end
    end
  end
end
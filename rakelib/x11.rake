namespace "x11" do
  desc "Install X11"
  task :install do
    xquartz_root = 'https://dl.bintray.com/xquartz/downloads'
    release = '2.7.8'
    dmg = "XQuartz-#{release}.dmg"
    dmg_url = "#{xquartz_root}/#{dmg}"
    pkg_download(dmg_url) do |p|
      dmg_mount(p) { |d| pkg_install(File.join(d, "XQuartz.pkg")) }
    end
    
  end
  
  desc "Uninstall X11"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      if File.exist?('/opt/X11/bin/Xorg')
        pkg_uninstall("org.macosforge.xquartz.pkg")
      else
        puts "XQuartz X11 is not installed"
      end
    end
  end
end
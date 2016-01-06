# Leiningen/Clojure tasks

require 'open3'

lein = File.expand_path("~/.bin/lein")
lein_home = File.expand_path("~/.lein")

namespace "leiningen" do
  desc "Install leiningen and clojure"
  task :install do
    # Download lein script
    url = "https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein"
    unless File.exist?(lein)
      fetch(url, lein)
      system "chmod a+x #{lein}"
    end
    puts %x{lein version}
  end
  
  desc "Uninstall leiningen and clojure"
  task :uninstall do
    file_remove lein
    file_remove lein_home
  end
  
  desc "Update leiningen and clojure"
  task :update do
    IO.popen("lein upgrade", 'w') do |io|
      io.write "y"
    end
  end
end

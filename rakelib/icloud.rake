# iCloud tasks

namespace "icloud" do
  desc "Install iCloud"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      icloud_dir = File.join(home_dir(), "Library", "Mobile Documents", "com~apple~CloudDocs")
      link_file icloud_dir, File.join(home_dir(), "iCloud")
    end
  end
  
  desc "Uninstall iCloud"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      file_remove(File.join(home_dir(), "iCloud"))
    end
  end
end

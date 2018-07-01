# iCloud tasks

if Bootstrap.macosx?
  namespace 'icloud' do
    desc 'Install iCloud'
    task :install do
      icloud_dir = File.join(Bootstrap.home_dir, 'Library', 'Mobile Documents', 'com~apple~CloudDocs')
      Bootstrap.link_file icloud_dir, File.join(Bootstrap.home_dir, 'iCloud')
    end

    desc 'Uninstall iCloud'
    task :uninstall do
      Bootstrap.file_remove(File.join(Bootstrap.home_dir, 'iCloud'))
    end
  end
end

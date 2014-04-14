# Sublime Text tasks

namespace "sublime" do
  desc "Install sublime"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      subl_root = File.expand_path("/Applications/Sublime Text.app/Contents/SharedSupport")
    end
    if File.exist?(subl_root)
      # Symlink sublime programs
      subl_path = File.join(subl_root, 'bin', 'subl')
      usr_bin = '/usr/local/bin'
      if File.exist?(subl_path)
        ln_path = File.join(usr_bin, 'subl')
        sudo "ln -s \"#{subl_path}\" \"#{ln_path}\"" unless File.exist?(ln_path)
      end
    end
  end

  desc "Uninstall sublime"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      subl_path = '/usr/local/bin/subl'
    end
    if File.exist?(subl_path)
      sudo_remove(subl_path)
    end

  end
end

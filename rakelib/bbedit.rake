
# BBEdit tasks
# defaults write com.barebones.bbedit CloseOFBNWindowAfterOpeningSelection -bool YES

namespace "bbedit" do
  desc "Install bbedit"
  task :install do
    domain = "com.barebones.bbedit"
    
    if RUBY_PLATFORM =~ /darwin/
      # TODO: Install bbedit
      # TODO: Set license key
      # TODO: Install command line utils
      
      if File.exist?("/Applications/BBEdit.app")
        # Set preferences
        defaults_write(domain, "CloseOFBNWindowAfterOpeningSelection", "YES", "-bool")
      end
    end
  end

  desc "Uninstall bbedit"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      if File.exist?("/Applications/BBEdit.app")
        # TODO: Remove BBEdit and settings
      end
    end
  end
end

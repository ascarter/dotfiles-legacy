# Tools from homebrew

brew_tools = %w(bash-completion gist graphviz jq memcached protobuf redis unar wget)
brew_taps = %w(universal-ctags/universal-ctags)
brew_overrides = %w(ctags)

namespace "brewtools" do
  desc "Install tools"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      # Install tools from homebrew
      brew_tools.each { |p| brew_install(p) }
      
      # Install taps
      brew_taps.each do |p|
        parts = p.split("/")
        brew_tap("#{parts[0]}/#{parts[1]}")
        brew_install(parts[1], "--HEAD")
      end
      
      # Symlink homebrew overrides to /usr/local
      brew_overrides.each { |p| usr_bin_ln(brew_bin_path(p), p) }
    end
  end

  desc "Uninstall tools"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      brew_tools.each { |p| brew_uninstall(p) }
      brew_taps.each { |p| brew_untap(p) }
      brew_overrides.each { |p| usr_bin_rm(p) }
    end
  end
end

# Tools from homebrew

brew_tools = %w(ctags gist jq memcached protobuf redis wget)

namespace "brewtools" do
  desc "Install tools"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      # Install tools from homebrew
      brew_tools.each { |item| brew_install(item) }
    end
  end

  desc "Uninstall tools"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      brew_tools.each { |item| brew_uninstall(item) }
    end
  end
end

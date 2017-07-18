# Vim tasks

VIM_APP_NAME = 'MacVim'.freeze
VIM_SOURCE_URL = 'https://github.com/macvim-dev/macvim/releases/download/snapshot-134/MacVim.dmg'.freeze

namespace 'vim' do
  desc 'Install vim'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(VIM_APP_NAME, VIM_SOURCE_URL, cmdfiles: ['mvim'])
    end

    user_vim_path = File.expand_path(File.join(Bootstrap.home_dir, '.vim'))
    mkdir(user_vim_path) unless File.exist?(user_vim_path)

    puts `vim --version`
  end

  desc 'Uninstall vim'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      # Remove MacVim
      Bootstrap::MacOSX::App.uninstall(VIM_APP_NAME)
    end
  end

  desc 'Update vim'
  task update: [:uninstall, :install]
end

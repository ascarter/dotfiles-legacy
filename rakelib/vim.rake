# Vim tasks

VIM_APP_NAME = 'MacVim'.freeze
VIM_SOURCE_URL = 'https://github.com/macvim-dev/macvim/releases/download/snapshot-127/MacVim.dmg'.freeze
VIM_TOOLS = %w(gvim mvimdiff mview mex rmvim vim).freeze

namespace 'vim' do
  desc 'Install vim'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(VIM_APP_NAME, VIM_SOURCE_URL, cmdfiles: ['mvim'])

      # Symlink vim programs to mvim on mac
      mvim = '/usr/local/bin/mvim'
      if Bootstrap.usr_bin_exists?("mvim")
        mvim = Bootstrap.usr_bin_cmd("mvim")
        # Gui, Diff, Read-only, Ex, Restricted
        VIM_TOOLS.each { |p| Bootstrap.usr_bin_ln(mvim, p) }
      end
    end

    user_vim_path = File.expand_path(File.join(Bootstrap.home_dir, '.vim'))
    mkdir(user_vim_path) unless File.exist?(user_vim_path)

    puts `vim --version`
  end

#   Rake::Task['vim:install'].enhance do
#     Rake::Task['vim:vundle'].invoke
#   end

  desc 'Update vundle'
  task :vundle do
    vundle_path = File.expand_path(File.join(Bootstrap.home_dir, '.vim/bundle/vundle'))
    if File.exist?(vundle_path)
      puts 'Update vundle'
      Bootstrap::Git.pull(vundle_path)
    else
      Bootstrap::Git.clone('gmarik/vundle', vundle_path)
    end
    system 'vim +PluginInstall +qall'
  end

  desc 'Uninstall vim'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      # Remove symlinks
      VIM_TOOLS.each { |p| Bootstrap.usr_bin_rm(p) }
      
      # Remove mvim
      Bootstrap.usr_bin_rm("mvim")

      # Remove bundles
      bundle_path = File.expand_path(File.join(Bootstrap.home_dir, '.vim/bundle'))
      Bootstrap.file_remove(bundle_path) if File.exist?(bundle_path)

      # Remove MacVim
      Bootstrap::MacOSX::App.uninstall(VIM_APP_NAME)
    end
  end

  desc 'Update vim'
  task update: [:uninstall, :install]
end

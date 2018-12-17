# Homebrew tasks

namespace 'homebrew' do
  directory Homebrew::ROOT do
    sudo_mkdir Homebrew::ROOT
    sudo_chown Homebrew::ROOT
    sudo_chgrp Homebrew::ROOT
    sudo_chmod Homebrew::ROOT

    bin_path = File.join(Homebrew::ROOT, 'bin')
    MacOS.path_helper 'homebrew', [ bin_path ]
    system "curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C #{Homebrew::ROOT}"
  end

#   desc 'Install Homebrew'
#   task :install do
#     if Dir.exist?(Homebrew::ROOT)
#       puts 'Homebrew already installed'
#       return
#     end
#
#     Bootstrap.sudo_mkdir Homebrew::ROOT
#     Bootstrap.sudo_chown Homebrew::ROOT
#     Bootstrap.sudo_chgrp Homebrew::ROOT
#     Bootstrap.sudo_chmod Homebrew::ROOT
#
#     bin_path = File.join(Homebrew::ROOT, 'bin')
#     MacOS.path_helper 'homebrew', [ bin_path ]
#     system "curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C #{Homebrew::ROOT}"
#
#     # Add brew to active shell path
#     ENV['PATH'] += ":#{bin_path}"
#   end

  desc 'Uninstall Homebrew'
  task :uninstall do
    raise('Homebrew not installed') unless Dir.exist?(Homebrew::ROOT)
    system 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"'
    sudo_rmdir Homebrew::ROOT
    MacOS.rm_path_helper 'homebrew'
  end
end

# Homebrew tasks

HOMEBREW_PATH_HELPER = File.join(VOLUME_ROOT, 'etc', 'paths.d', 'homebrew')
HOMEBREW_PATHS = FileList[ File.join(HOMEBREW_PREFIX, 'bin') ]

namespace 'homebrew' do
  directory HOMEBREW_PREFIX do
    sudo <<-END
      mkdir -p #{HOMEBREW_PREFIX}
      chown -R #{current_user} #{HOMEBREW_PREFIX}
      chgrp -R admin #{HOMEBREW_PREFIX}
      chmod g+w #{HOMEBREW_PREFIX}
    END
    system "curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C #{HOMEBREW_PREFIX}"
  end

  file HOMEBREW_PATH_HELPER => [HOMEBREW_PATHS] do |t|
    MacOS.path_helper t.name, t.prerequisites
  end

  desc 'Install Homebrew'
  task :install => [ HOMEBREW_PREFIX, HOMEBREW_PATH_HELPER ]

  desc 'Uninstall Homebrew'
  task :uninstall do
    raise('Homebrew not installed') unless Dir.exist?(HOMEBREW_PREFIX)
    sudo "rm #{HOMEBREW_PATH_HELPER}"
    system %(ruby -e 'puts ARGV' -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)" -- --path=#{HOMEBREW_PREFIX})
    sudo "rm -Rf #{HOMEBREW_PREFIX}"
  end
end

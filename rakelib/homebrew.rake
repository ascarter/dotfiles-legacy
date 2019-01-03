# Homebrew tasks

HOMEBREW_PREFIX = ENV['HOMEBREW_PREFIX'] || File.join(VOLUME_ROOT, 'opt', 'homebrew')
HOMEBREW_PATH_HELPER = File.join(VOLUME_ROOT, 'etc', 'paths.d', 'homebrew')
HOMEBREW_PATHS = FileList[ File.join(HOMEBREW_PREFIX, 'bin') ]

task :env do
  puts "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}"
end

namespace 'homebrew' do
  file HOMEBREW_PREFIX do |t|
    sudo <<-END
      mkdir -p #{t.name}
      chown -R #{current_user} #{t.name}
      chgrp -R admin #{t.name}
      chmod g+w #{t.name}
    END
    sh "curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C #{t.name}"
  end

  file HOMEBREW_PATH_HELPER => [ HOMEBREW_PATHS ] do |t|
    MacOS.path_helper t.name, t.sources
  end

  desc 'Install Homebrew'
  task :install => [ HOMEBREW_PREFIX, HOMEBREW_PATH_HELPER ]

  desc 'Uninstall Homebrew'
  task :uninstall do
    return unless Dir.exist?(HOMEBREW_PREFIX)
    sudo "rm #{HOMEBREW_PATH_HELPER}" if File.exist?(HOMEBREW_PATH_HELPER)
    sudo %(ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)" -- --path=#{HOMEBREW_PREFIX})
    sudo "rm -Rf #{HOMEBREW_PREFIX}" if Dir.exist?(HOMEBREW_PREFIX)
  end
end

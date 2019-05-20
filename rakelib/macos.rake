if macOS?
  ICLOUD_SOURCE = File.join(home_dir, 'Library', 'Mobile Documents', 'com~apple~CloudDocs')
  ICLOUD_LINK = File.join(HOME_ROOT, 'iCloud')

  CLOBBER.include ICLOUD_LINK

  file ICLOUD_LINK => ICLOUD_SOURCE do |t|
    ln_s t.source, t.name
  end

  PIP = File.join(home_dir, 'Library', 'Python', '2.7', 'bin', 'pip')
  file PIP do
    Pip.bootstrap
  end

  task :osinstall => [ICLOUD_LINK, PIP, 'homebrew:install'] do
    MacOS.build_locatedb
  end

  task :base_packages do
    # Set homebrew
    Homebrew.prefix HOMEBREW_PREFIX

    packages = {
      taps: [
        'universal-ctags/universal-ctags'
      ],
      pkgs: [
        'bash-completion',
        'gist',
        'htop',
        'hub',
        'jq',
        'ranger',
        'unar',
        'wget',
        '--HEAD universal-ctags'
      ],
      casks: [
        'android-file-transfer',
        'android-studio',
        'bbedit',
        'coderunner',
        'nightowl',
        'xquartz'
      ]
    }

    Homebrew.collection packages
  end
end

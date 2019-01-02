if macOS?
  ICLOUD_DIR = File.join(home_dir, 'Library', 'Mobile Documents', 'com~apple~CloudDocs')
  ICLOUD_LINK = File.join(HOME_ROOT, 'iCloud')

  CLOBBER.include ICLOUD_LINK

	task :osinstall => [ 'icloud:install', 'homebrew:install' ] do
	  puts "Start locate database rebuild job..."
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
        'universal-ctags/universal-ctags --HEAD'
      ],
      casks: [
        'android-file-transfer',
        'android-studio',
        'coderunner',
        'nightowl'
      ]
	  }

    Homebrew.collection packages
  end

  namespace 'icloud' do
    file ICLOUD_LINK => ICLOUD_DIR do |t|
      ln_s t.source, t.name
    end

    desc 'Install iCloud'
    task :install => [ ICLOUD_LINK ]

    desc 'Uninstall iCloud'
    task :uninstall do
      rm ICLOUD_LINK
    end
  end
end

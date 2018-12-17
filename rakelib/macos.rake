if RUBY_PLATFORM =~ /darwin/
  ICLOUD_DIR = File.join(DEST_ROOT, 'Library', 'Mobile Documents', 'com~apple~CloudDocs')
  ICLOUD_LINK = File.join(DEST_ROOT, 'iCloud')

	task :osinstall => [
		Homebrew::ROOT,
		ICLOUD_LINK
	]

	task :base_packages do
    taps = [
      'universal-ctags/universal-ctags'
    ]

    pkgs = [
      'bash-completion',
      'gist',
      'htop',
      'hub',
      'jq',
      'ranger',
      'unar',
      'wget',
      'universal-ctags/universal-ctags --HEAD'
    ]

    casks = [
      'android-file-transfer',
      'android-studio',
      'coderunner',
      'nightowl'
    ]

    Homebrew.collection taps: taps, pkgs: pkgs, casks: casks
  end

  namespace 'icloud' do
    file ICLOUD_LINK => ICLOUD_DIR do |t|
      ln_s t.name, t.source
    end

    desc 'Uninstall iCloud'
    task :uninstall do
      rm ICLOUD_LINK
    end
  end
end

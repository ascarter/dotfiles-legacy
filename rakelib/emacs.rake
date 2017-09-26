# Emacs tasks

EMACS_APP_NAME = 'Emacs'.freeze
EMACS_SOURCE_URL = 'https://emacsformacosx.com/emacs-builds/Emacs-25.1-1-universal.dmg'.freeze

namespace 'emacs' do
  desc 'Install Emacs'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(EMACS_APP_NAME, EMACS_SOURCE_URL)

      # Symlink emacs
      emacs = File.expand_path(File.join(File.dirname(__FILE__), '../src/bin/memacs'))
      Bootstrap.usr_bin_ln(emacs, 'emacs')

      # Symlink emacsclient
      emacsclient = '/Applications/Emacs.app/Contents/MacOS/bin/emacsclient'
      Bootstrap.usr_bin_ln(emacsclient, 'emacsclient')
    end

    puts `emacs --version`
  end

  desc 'Uninstall Emacs'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      # Remove symlinks
      %w(emacs emacsclient).each { |c| Bootstrap.usr_bin_rm(c) }

      # Remove application
      Bootstrap::MacOSX::App.uninstall(EMACS_APP_NAME)
    end
  end

  desc 'Update emacs'
  task update: [:uninstall, :install]
end

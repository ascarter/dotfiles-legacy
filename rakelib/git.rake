# Git tasks

GITHUB_CONFIG_FILES = %w(~/.config/hub)

namespace 'git' do
  desc 'Update git config'
  task :config do
    puts 'Setting git config'
    source = File.expand_path('gitconfig')
    target = File.join(Bootstrap.home_dir, '.gitconfig')

    # Read current user and email if previously configured
    if File.exist?(target)
      userName = Git::Config.get('user.name')
      userEmail = Git::Config.get('user.email')
      userGPGKey = Git::Config.get('user.signingkey')
      userDefaultSign = Git::Config.get('commit.gpgsign')
    end

    if userName.nil? || userName.empty?
      # Get user and email
      uinfo = Etc.getpwnam(Etc.getlogin)
      userName = uinfo.gecos
    end

    # TODO: get email from the GitHub user that checked out the repo
    # userEmail = '...'

    Bootstrap.copy_and_replace(source, target)

    # Set user, email, and signing key
    name = Bootstrap.prompt('user name', userName)
    email = Bootstrap.prompt('user email', userEmail)
    signingKey = Bootstrap.prompt('user signingkey', userGPGKey)
    defaultSign = Bootstrap.prompt('gpgsign by default?', userDefaultSign == 'true' ? 'Y' : 'N')

    Git::Config.set('user.name', name)
    Git::Config.set('user.email', email)
    if signingKey.nil? || signingKey.empty?
      Git::Config.unset('user.signingkey')
      Git::Config.unset('commit.gpgsign')
    else
      Git::Config.set('user.signingkey', signingKey)
      if defaultSign.upcase.start_with?('Y')
        Git::Config.set('commit.gpgsign', true)
      else
        Git::Config.unset('commit.gpgsign')
      end
    end

    # Set git commit editor
    if File.exist? Bootstrap.usr_bin_cmd('bbedit')
      # bbedit
      Git::Config.set('core.editor', 'bbedit --wait')
    else
      # vim
      Git::Config.set('core.editor', 'vim')
    end

    case RUBY_PLATFORM
    when /darwin/
      # Configure password caching
      Git::Config.set('credential.helper', 'osxkeychain')

      if File.exist? Bootstrap.usr_bin_cmd('bbdiff')
        # bbedit
        Git::Config.set('diff.tool', 'bbdiff')
        Git::Config.set('merge.tool', 'opendiff')
      elsif File.exist? Bootstrap.usr_bin_cmd('ksdiff')
        # Configure Kaleidoscope
        Git::Config.set('diff.tool', 'Kaleidoscope')
        Git::Config.set('merge.tool', 'Kaleidoscope')
      else
        Git::Config.set('diff.tool', 'opendiff')
        Git::Config.set('merge.tool', 'opendiff')
      end

      Git::Config.set('gui.fontui', '-family \"SF UI Display Regular\" -size 11 -weight normal -slant roman -underline 0 -overstrike 0')
      Git::Config.set('gui.fontdiff', '-family Menlo -size 12 -weight normal -slant roman -underline 0 -overstrike 0')

    when /linux/
      # Configure password caching
      Git::Config.set('credential.helper', 'cache')

      Git::Config.set('diff.tool', 'meld')
      Git::Config.set('merge.tool', 'meld')

      Git::Config.set('gui.fontui', '-family \"Source Sans Pro\" -size 12 -weight normal -slant roman -underline 0 -overstrike 0')
      Git::Config.set('gui.fontdiff', '-family \"Source Code Pro\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0')
    end
  end

  desc 'Reset config files for GitHub tools'
  task :reset do
    GITHUB_CONFIG_FILES.each { |f| rm f }
  end
end

require 'erb'

GIT_CONFIG_TEMPLATE = File.expand_path('templates/gitconfig')
GIT_CONFIG = File.join(HOME_ROOT, '.gitconfig')
GIT_IGNORE_TEMPLATE = File.expand_path('templates/gitignore')
GIT_IGNORE = File.join(HOME_ROOT, '.gitignore')
GITHUB_CONFIG = File.join(HOME_ROOT, '.config', 'hub')

namespace 'git' do
  desc 'Update git config'
  task :config do
    # Set config file
    Git::Config.file(GIT_CONFIG)

    # Read current user and email if previously configured
    if File.exist?(GIT_CONFIG)
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

    # Set binding variables

    # Write template to gitconfig file
    erb = ERB.new(File.read(GIT_CONFIG_TEMPLATE))
    File.write(GIT_CONFIG, erb.result(binding))

    # Set user, email, and signing key
    name = prompt('user name', userName)
    Git::Config.set('user.name', name)

    email = prompt('user email', userEmail)
    Git::Config.set('user.email', email)

    signingKey = prompt('user signingkey', userGPGKey)
    defaultSign = prompt('gpgsign by default?', userDefaultSign == 'true' ? 'Y' : 'N')
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
    Git::Config.set('core.editor', File.exist?(File.join(USR_LOCAL_ROOT, 'bin', 'bbedit')) ? 'bbedit --wait' : 'vim')
    Git::Config.set('core.editor', 'vim')

    case RUBY_PLATFORM
    when /darwin/
      # Configure password caching
      Git::Config.set('credential.helper', 'osxkeychain')

      Git::Config.set('diff.tool', File.exist?(File.join(USR_LOCAL_ROOT, 'bin', 'bbdiff')) ? 'bbdiff' : 'opendiff')
      Git::Config.set('merge.tool', 'opendiff')

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

  desc 'Set global gitignore'
  task :ignore do
    erb = ERB.new(File.read(GIT_IGNORE_TEMPLATE))
    File.write(GIT_IGNORE, erb.result(binding))
  end

  desc 'Reset config files for GitHub tools'
  task :reset do
    rm GITHUB_CONFIG
  end
end

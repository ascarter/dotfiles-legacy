require 'erb'

GIT_CONFIG = File.join(HOME_ROOT, '.gitconfig')
GIT_IGNORE = File.join(HOME_ROOT, '.gitignore')
GITHUB_CONFIG = File.join(HOME_ROOT, '.config', 'hub')

namespace 'git' do
  desc 'Update git config'
  task :config => [ GIT_CONFIG, GIT_IGNORE ]

  file GIT_CONFIG => [ 'templates/gitconfig' ] do |t|
    # Write template to gitconfig file
    erb = ERB.new(File.read(t.source))
    File.write(t.name, erb.result(binding))

    # Set config file
    Git::Config.file(t.name)

    # Get user and email
    uinfo = Etc.getpwnam(Etc.getlogin)
    userName = uinfo.gecos
    userEmail = Git::Config.get('user.email')

    # Get GPG key (if any)
    userGPGKey = Git::Config.get('user.signingkey')
    userDefaultSign = Git::Config.get('commit.gpgsign')

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

  file GIT_IGNORE => [ 'templates/gitignore' ] do |t|
    erb = ERB.new(File.read(t.source))
    File.write(t.name, erb.result(binding))
  end

  desc 'Reset config files for git'
  task :reset do
    rm GITHUB_CONFIG
    rm GIT_IGNORE
    rm GIT_CONFIG
  end
end

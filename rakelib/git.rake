# Git tasks

require 'etc'

namespace 'git' do
  desc 'Update git config'
  task :config do
    puts 'Setting git config'
    source = File.expand_path('gitconfig')
    target = File.join(Bootstrap.home_dir(), '.gitconfig')
    
    # Read current user and email if previously configured
    if File.exist?(target)
      userName = Bootstrap::Git::Config.get('user.name')
      userEmail = Bootstrap::Git::Config.get('user.email')
      userGPGKey = Bootstrap::Git::Config.get('user.signingkey')
    end
    
    if userName.empty?
      # Get user and email
      uinfo = Etc.getpwnam(Etc.getlogin)
      userName = uinfo.gecos
    end

    # TODO: get email from the GitHub user that checked out the repo
    # userEmail = '...'
    
    Bootstrap.copy_and_replace(source, target)

    # Set user and email
    name = Bootstrap.prompt('user name', userName)
    email = Bootstrap.prompt('user email', userEmail)
    signingKey = Bootstrap.prompt('user signingkey', userGPGKey)

    Bootstrap::Git::Config.set('user.name', name)
    Bootstrap::Git::Config.set('user.email', email)
    Bootstrap::Git::Config.set('user.signingkey', signingKey) unless signingKey.empty?

    # Set git commit editor
    if File.exist?(File.expand_path('/usr/local/bin/bbedit'))
        # bbedit
        Bootstrap::Git::Config.set('core.editor', 'bbedit --wait')
    else
        # vim
        Bootstrap::Git::Config.set('core.editor', 'vim')
    end

    case RUBY_PLATFORM
    when /darwin/
      # Configure password caching
      Bootstrap::Git::Config.set('credential.helper', 'osxkeychain')

      if File.exist?(File.expand_path('/usr/local/bin/bbdiff'))
        # bbedit
        Bootstrap::Git::Config.set('diff.tool', 'bbdiff')
        Bootstrap::Git::Config.set('merge.tool', 'opendiff')          
      elsif File.exist?(File.expand_path('/usr/local/bin/ksdiff'))
        # Configure Kaleidoscope
        Bootstrap::Git::Config.set('diff.tool', 'Kaleidoscope')
        Bootstrap::Git::Config.set('merge.tool', 'Kaleidoscope')
      else
        Bootstrap::Git::Config.set('diff.tool', 'opendiff')
        Bootstrap::Git::Config.set('merge.tool', 'opendiff')
      end

      Bootstrap::Git::Config.set('gui.fontui', '-family \"SF UI Display Regular\" -size 11 -weight normal -slant roman -underline 0 -overstrike 0')
      Bootstrap::Git::Config.set('gui.fontdiff', '-family Menlo -size 12 -weight normal -slant roman -underline 0 -overstrike 0')
      
    when /linux/
      # Configure password caching
      Bootstrap::Git::Config.set('credential.helper', 'cache')

      Bootstrap::Git::Config.set('diff.tool', 'meld')
      Bootstrap::Git::Config.set('merge.tool', 'meld')
      
      Bootstrap::Git::Config.set('gui.fontui', '-family \"Source Sans Pro\" -size 12 -weight normal -slant roman -underline 0 -overstrike 0')
      Bootstrap::Git::Config.set('gui.fontdiff', '-family \"Source Code Pro\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0')
    end
  end
end

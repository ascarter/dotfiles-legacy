# Git tasks

require 'etc'
require 'uri'

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

# git helpers
module Git
  module_function

  # git configuration
  module Config
    module_function

    def get(key)
      `git config --global --get #{key}`.strip
    end

    def set(key, value)
      system %(git config --global #{key} "#{value}")
    end

    def unset(key)
      system %(git config --global --unset #{key})
    end
  end

  def clone(repo, dest = nil)
    git_url = URI.join('https://github.com/', "#{repo}.git").to_s
    system %(git clone #{git_url} #{dest ? dest.to_s : ''})
  end

  def fetch(path)
    system "cd #{path} && git fetch origin"
  end

  def pull(path)
    system "cd #{path} && git pull" if File.directory?(path)
  end

  def checkout(path, tag)
    puts "checking out #{tag}"
    system "cd #{path} && git checkout -q #{tag}" if File.directory?(path)
  end

  def set_remote_ssh(name = 'origin')
    # Get current remote URL
    old_url = `git remote get-url #{name}`.strip

    # Check if HTTP uri
    return unless URI.regexp(['http', 'https']).match(old_url)

    # Convert http URL to ssh
    old_uri = URI(old_url)
    new_uri = "git@#{old_uri.host}:#{old_uri.path[1..-1]}"

    puts "Switch git remote URL from #{old_uri} to #{new_uri}"
    `git remote set-url #{name} #{new_uri}`
  end

  def latest_tag(path, filter = nil)
    args = %w(--abbrev=0 --tags)
    args << %(--match "#{filter}")
    `cd #{path} && git describe #{args.join(" ")} origin`
  end
end

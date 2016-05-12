# Git tasks

require 'etc'

namespace "git" do
  desc "Update git config"
  task :config do
    puts "Setting git config"
    source = File.expand_path('gitconfig')
    target = File.join(Bootstrap.home_dir(), '.gitconfig')
    Bootstrap.copy_and_replace(source, target)

    # Get user and email
    uinfo = Etc.getpwnam(Etc.getlogin)
    name = Bootstrap.prompt("user name", uinfo.gecos)
    # TODO: get email from the GitHub user that checked out the repo
    email = Bootstrap.prompt("user email", "ascarter@icloud.com")
    Bootstrap::Git.config("user.name", name)
    Bootstrap::Git.config("user.email", email)

    # Set git commit editor
    if File.exist?(File.expand_path('/usr/local/bin/bbedit'))
        # bbedit
        Bootstrap::Git.config("core.editor", "bbedit --wait")
    else
        # vim
        Bootstrap::Git.config("core.editor", "vim")
    end

    case RUBY_PLATFORM
    when /darwin/
      # Configure password caching
      Bootstrap::Git.config("credential.helper", "osxkeychain")

      if File.exist?(File.expand_path('/usr/local/bin/bbdiff'))
        # bbedit
        Bootstrap::Git.config("diff.tool", "bbdiff")
        Bootstrap::Git.config("merge.tool", "opendiff")          
      elsif File.exist?(File.expand_path('/usr/local/bin/ksdiff'))
        # Configure Kaleidoscope
        Bootstrap::Git.config("diff.tool", "Kaleidoscope")
        Bootstrap::Git.config("merge.tool", "Kaleidoscope")
      else
        Bootstrap::Git.config("diff.tool", "opendiff")
        Bootstrap::Git.config("merge.tool", "opendiff")
      end

      Bootstrap::Git.config("gui.fontui", '-family \"SF UI Display Regular\" -size 11 -weight normal -slant roman -underline 0 -overstrike 0')
      Bootstrap::Git.config("gui.fontdiff", '-family Menlo -size 12 -weight normal -slant roman -underline 0 -overstrike 0')
    when /linux/
      # Configure password caching
      Bootstrap::Git.config("credential.helper", "cache")

      Bootstrap::Git.config("diff.tool", "meld")
      Bootstrap::Git.config("merge.tool", "meld")
      
      Bootstrap::Git.config("gui.fontui", '-family \"Source Sans Pro\" -size 12 -weight normal -slant roman -underline 0 -overstrike 0')
      Bootstrap::Git.config("gui.fontdiff", '-family \"Source Code Pro\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0')
    end
  end
end

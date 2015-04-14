# Git tasks

require 'etc'

namespace "git" do
  desc "Update git config"
  task :config do
    puts "Setting git config"
    source = File.expand_path('gitconfig')
    target = File.join(File.expand_path(ENV['HOME']), '.gitconfig')
    copy_and_replace(source, target)

    # Get user and email
    uinfo = Etc.getpwnam(Etc.getlogin)
    name = prompt("user name", uinfo.gecos)
    # TODO: get email from the GitHub user that checked out the repo
    email = prompt("user email", "ascarter@icloud.com")
    git_config("user.name", name)
    git_config("user.email", email)

    # Set git commit editor
    if File.exist?(File.expand_path('/usr/local/bin/bbedit'))
        # bbedit
        git_config("core.editor", "bbedit --wait")
    elsif File.exist?(File.expand_path('/usr/local/bin/atom'))
        # atom
        git_config("core.editor", "atom --wait")
    else
        # vim
        git_config("core.editor", "vim")
    end

    if RUBY_PLATFORM =~ /darwin/
      # Configure password caching
      git_config("credential.helper", "osxkeychain")

      if File.exist?(File.expand_path('/usr/local/bin/bbdiff'))
        # bbedit
        git_config("diff.tool", "bbdiff")
        git_config("merge.tool", "bbdiff")          
      elsif File.exist?(File.expand_path('/usr/local/bin/ksdiff'))
        # Configure Kaleidoscope
        git_config("diff.tool", "Kaleidoscope")
        git_config("merge.tool", "Kaleidoscope")
      end

      git_config("gui.fontui", '-family \"Lucida Grande\" -size 11 -weight normal -slant roman -underline 0 -overstrike 0')
      git_config("gui.fontdiff", '-family Menlo -size 12 -weight normal -slant roman -underline 0 -overstrike 0')
    elsif RUBY_PLATFORM =~ /linux/
      # Configure password caching
      git_config("credential.helper", "cache")

      git_config("diff.tool", "meld")
      git_config("gui.fontui", '-family \"Source Sans Pro\" -size 12 -weight normal -slant roman -underline 0 -overstrike 0')
      git_config("gui.fontdiff", '-family \"Source Code Pro\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0')
    end
  end
end

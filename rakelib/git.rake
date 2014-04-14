# Git tasks

namespace "git" do
  desc "Update git config"
  task :config do
    puts "Setting git config"
    source = File.expand_path('gitconfig')
    target = File.join(File.expand_path(ENV['HOME']), '.gitconfig')
    copy_and_replace(source, target)

    name = prompt("user name")
    email = prompt("user email")
    sh "git config --global user.name \"#{name}\""
    sh "git config --global user.email \"#{email}\""

    # Set git commit editor
    atom = File.expand_path('/usr/local/bin/atom')
    if File.exist?(atom)
      sh "git config --global core.editor \"atom --wait\""
    end

    # Configure password caching
    if RUBY_PLATFORM =~ /darwin/
      sh "git config --global credential.helper osxkeychain"
      sh "git config --global merge.tool Kaleidoscope"
      sh "git config --global diff.tool Kaleidoscope"
      sh "git config --global gui.fontui '-family \"Lucida Grande\" -size 11 -weight normal -slant roman -underline 0 -overstrike 0'"
    sh "git config --global gui.fontdiff '-family Menlo -size 12 -weight normal -slant roman -underline 0 -overstrike 0'"
    elsif RUBY_PLATFORM =~ /linux/
      sh "git config --global credential.helper cache"
      # sh "git config --global merge.tool Kaleidoscope"
      sh "git config --global diff.tool meld"
      sh "git config --global gui.fontui '-family \"Source Sans Pro\" -size 12 -weight normal -slant roman -underline 0 -overstrike 0'"
      sh "git config --global gui.fontdiff '-family \"Source Code Pro\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'"
    end
  end
end

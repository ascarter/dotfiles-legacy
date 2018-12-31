require 'etc'
require 'uri'

# git helpers
module Git
  module_function

  # git configuration
  module Config
    module_function

    def command
      @cmd || "git config #{@file.nil? ? '--global' : "--file #{@file}"}"
    end

    def file(fname)
      @file = fname
    end

    def get(key)
      `#{command} --get #{key}`.strip
    end

    def set(key, value)
      system %(#{command} #{key} "#{value}")
    end

    def unset(key)
      system %(#{command} --unset #{key})
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

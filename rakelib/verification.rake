require 'digest'

namespace 'ssh' do
  desc 'Install ssh client support'
  task :install => [ 'ssh:keygen', 'ssh:config' ]

  desc 'Configure ssh client'
  task :config do
    source = File.expand_path('sshconfig')
    target = File.join(Bootstrap.home_dir, '.ssh', 'config')
    Bootstrap.copy_and_replace source, target
  end

  desc 'Generate key'
  task :keygen do
    keyfile = Bootstrap.prompt('keyfile', File.join(Bootstrap.ssh_dir, 'id_rsa'))
    if File.exist?(keyfile)
      puts "SSH key exists"
    else
      email = Bootstrap.prompt('email', '')
      system %Q(ssh-keygen -t rsa -b 4096 -C "#{email}" -f #{keyfile})
    end
  end
end

module Verification
  module_function

  # Digest
  def sha1(path)
    if File.exist?(path)
      contents = File.read(path)
      return Digest::SHA1.hexdigest(contents)
    end
  end

  def sha256(path)
    if File.exist?(path)
      contents = File.read(path)
      return Digest::SHA256.hexdigest(contents)
    end
  end

  # GPG
  def gpg(target, sig)
    `gpg --verify #{sig} #{target}`
  end

  # PGP
  def pgp(sig)
    system "keybase pgp verify -m '#{sig}'"
    return $?
  end
end

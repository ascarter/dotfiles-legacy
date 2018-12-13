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

  desc 'Add SSH key to GitHub and switch remote origin to SSH'
  task :github do
    pub_key_file = File.join(Bootstrap.ssh_dir, 'id_rsa')
    raise 'Key file missing' unless File.exist? pub_key_file
    `pbcopy < #{pub_key_file} && open "https://github.com/settings/ssh/new"`
    Bootstrap.prompt_to_continue

    # Switch GitHub enlistment to ssh
    Git.set_remote_ssh
  end
end

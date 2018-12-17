SSH_CONFIG = File.join(ssh_dir, 'config')
SSH_KEYFILE = File.join(ssh_dir, 'id_rsa')

namespace 'ssh' do
  file SSH_KEYFILE do
    email = Bootstrap.prompt('email', '')
    system %Q(ssh-keygen -t rsa -b 4096 -C "#{email}" -f #{SSH_KEYFILE})

    # Upload key to GitHub
    Rake::Task['ssh:github'].invoke
  end

  file SSH_CONFIG => [ 'sshconfig' ] do |t|
    cp t.source, t.name
  end

  desc 'Install ssh client support'
  task :install => [ SSH_KEYFILE, SSH_CONFIG ]

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

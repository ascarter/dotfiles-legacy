require 'erb'

SSH_DIR = File.join(HOME_ROOT, '.ssh')
SSH_CONFIG = File.join(SSH_DIR, 'config')
SSH_PRIVATE_KEY = File.join(SSH_DIR, 'id_rsa')
SSH_PUBLIC_KEY = File.join(SSH_DIR, 'id_rsa.pub')

namespace 'ssh' do
  desc 'Configure ssh client'
  task :config => [ SSH_DIR, SSH_CONFIG, SSH_PRIVATE_KEY ]

  directory SSH_DIR
  file SSH_DIR do |t|
    chmod 'go=-rwx', t.name
  end

  file SSH_PRIVATE_KEY => [ SSH_DIR ] do |t|
    email = request_input('email', '')
    sh %(ssh-keygen -t rsa -b 4096 -C "#{email}" -f #{t.name})
  end

  file SSH_CONFIG => [ SSH_DIR, 'templates/sshconfig' ] do |t|
    erb = ERB.new(File.read(t.sources[1]))
    File.write(t.name, erb.result(binding))
  end

  desc 'Add SSH key to GitHub and switch remote origin to SSH'
  task :github => [ SSH_PRIVATE_KEY ] do
    sh %(pbcopy < #{SSH_PUBLIC_KEY} && open "https://github.com/settings/ssh/new")
    prompt_to_continue

    # Switch GitHub enlistment to ssh
    Git.set_remote_ssh
  end
end

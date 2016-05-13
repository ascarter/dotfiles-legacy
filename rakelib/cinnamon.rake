# Cinnamon tasks

namespace "cinnamon" do
  desc "Install for Ubuntu"
  task :install do
    Bootstrap.sudo "sudo add-apt-repository ppa:gwendal-lebihan-dev/cinnamon-stable"
    Bootstrap.sudo "apt-get update"
    Bootstrap.sudo "apt-get install cinnamon"
  end
end

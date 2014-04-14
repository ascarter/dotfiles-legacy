# Cinnamon tasks

namespace "cinnamon" do
  desc "Install for Ubuntu"
  task :install do
    sudo "sudo add-apt-repository ppa:gwendal-lebihan-dev/cinnamon-stable"
    sudo "apt-get update"
    sudo "apt-get install cinnamon"
  end
end

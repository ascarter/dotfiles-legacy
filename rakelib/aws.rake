# AWS CLI

namespace "aws" do
  desc "Install AWS CLI"
  task :install do
    pip_install("awscli", true)
  end

  desc "Uninstall AWS CLI"
  task :uninstall do
    pip_uninstall("awscli", true)
  end
end

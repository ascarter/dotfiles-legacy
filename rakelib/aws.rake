# AWS tools

aws_pkgs = %w(awscli dynamodb-local)

namespace "aws" do
  desc "Install AWS CLI"
  task :install do
    if RUBY_PLATFORM =~ /darwin/
      aws_pkgs.each { |item| brew_install(item) }
    end
  end

  desc "Uninstall AWS CLI"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      aws_pkgs.each { |item| brew_uninstall(item) }
    end
  end
end

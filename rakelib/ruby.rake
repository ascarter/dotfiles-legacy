BUNDLE_CONFIG = File.join(home_dir, '.bundle', 'config')

# file BUNDLE_CONFIG do
#   system <<-EOF
#     bundle config --global default_install_uses_path true
#     bundle config --global gem.coc false
#     bundle config --global gem.mit true
#     bundle config --global gem.test minitest
#   EOF
# end

namespace 'ruby' do
  namespace 'bundler' do    
    desc 'Install Bundler'
    task :install do
      system "gem install --user-install bundler"
    end
    
    desc 'Configure Bundler'
    task :config => ['ruby:bundler:install'] do
      system <<-EOF
        bundle config --global default_install_uses_path true
        bundle config --global gem.coc false
        bundle config --global gem.mit true
        bundle config --global gem.test minitest
      EOF
    end
  end
end

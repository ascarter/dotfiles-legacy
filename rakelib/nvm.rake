# Node Version Manager tasks

namespace 'nvm' do
  desc 'Install nvm'
  task :install do
    nvm_root = File.expand_path(File.join(Bootstrap.home_dir, '.nvm'))
    Bootstrap::Git.clone('creationix/nvm', nvm_root)
  end

  Rake::Task[:install].enhance do
    Rake::Task['nvm:latest'].invoke
  end

  desc 'Uninstall nvm'
  task :uninstall do
    nvm_root = File.expand_path(File.join(Bootstrap.home_dir, '.nvm'))
    Bootstrap.file_remove(nvm_root)
  end

  desc 'Update nvm'
  task :update do
    nvm_root = File.expand_path(File.join(Bootstrap.home_dir, '.nvm'))
    Bootstrap::Git.fetch(nvm_root)
  end

  Rake::Task[:update].enhance do
    Rake::Task['nvm:latest'].invoke
  end

  task :latest do
    nvm_root = File.expand_path(File.join(Bootstrap.home_dir, '.nvm'))
    tag = Bootstrap::Git.latest_tag(nvm_root, "v[0-9]*")
    Bootstrap::Git.checkout(nvm_root, tag)
  end
end

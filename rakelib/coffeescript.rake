# Coffeescript tasks

namespace "coffeescript" do
  desc "Install coffeescript"
  task :install do
    %w{coffee-script coffeelint}.each { |p| npm_install p }
    puts %x{coffee --version}
  end

  desc "Uninstall coffeescript"
  task :uninstall do
    %w{coffee-script coffeelint}.each { |p| npm_uninstall p }
  end    
end

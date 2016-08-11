# Coffeescript tasks

COFFEESCRIPT_PKGS = %w(coffee-script coffeelint).freeze

namespace 'coffeescript' do
  desc 'Install coffeescript'
  task :install do
    COFFEESCRIPT_PKGS.each { |p| Bootstrap::NPM.install p }
    puts `coffee --version`
  end

  desc 'Uninstall coffeescript'
  task :uninstall do
    COFFEESCRIPT_PKGS.each { |p| Bootstrap::NPM.uninstall p }
  end
end

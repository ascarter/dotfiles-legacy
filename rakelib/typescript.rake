# TypeScript tasks

namespace "typescript" do
  desc "Install TypeScript"
  task :install do
    # Verify npm is installed
    unless File.exist?('/usr/local/bin/tsc')
      if File.exist?('/usr/local/bin/npm')
        # Install TypeScript via npm
        npm_install('typescript')
      else
        puts 'npm is not installed'
      end
    end

    puts %x{tsc --version}
  end

  desc "Uninstall TypeScript"
  task :uninstall do
    if File.exist?('/usr/local/bin/tsc')
      npm_uninstall('typescript')
    end
  end
end

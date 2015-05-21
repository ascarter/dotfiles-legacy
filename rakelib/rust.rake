# Rust language tasks

namespace "rust" do
  desc "Install Rust"
  task :install do
    root = File.expand_path('/usr/local')
    prog = File.join(root, 'bin', 'rustc')

    unless File.exist?(prog)
      # Download and install Rust
      system "curl -sSf https://static.rust-lang.org/rustup.sh | sh"
    end
    
    puts %x{#{prog} --version}
  end

  desc "Info on Rust"
  task :info do
    root = File.expand_path('/usr/local')
    prog = File.join(root, 'bin', 'rustc')
    if File.exist?(prog)
      puts %x{#{prog} --version}
    else
      puts "Rust is not installed"
    end
  end
  
  desc "Uninstall Rust"
  task :uninstall do
    puts "Uninstalling Rust..."
    script = File.expand_path('/usr/local/lib/rustlib/uninstall.sh')
    if File.exist?(script)
      sudo script
    else
      puts "Rust is not installed"
    end
  end
  
  desc "Update Rust"
  task update: [:uninstall, :install]
end

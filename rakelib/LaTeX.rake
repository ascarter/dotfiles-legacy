# LaTeX tasks

namespace "LaTeX" do
  desc "Install LaTeX"
  task :install do
    tex_root = File.expand_path('/usr/local/texlive')

    unless File.exist?(tex_root)
      if RUBY_PLATFORM =~ /darwin/
        # Download and install MacTeX
        pkg = 'MacTeX.pkg'
        pkg_url = "http://mirror.ctan.org/systems/mac/mactex/#{pkg}"
        pkg_download(pkg_url) do |p|
            pkg_install(p)
        end
      end
    end
    
    puts %x{texdist --current}
  end

  desc "Uninstall LaTeX"
  task :uninstall do
    puts "Uninstalling LaTeX..."
    tex_root = File.expand_path('/usr/local/texlive')
    if File.exist?(tex_root)
      if RUBY_PLATFORM =~ /darwin/
        packages = [
          'org.tug.mactex.ghostscript9.10',
          'org.tug.mactex.gui2014',
          'org.tug.mactex.texlive2014'
        ]
        packages.each { |p| pkg_uninstall(p) }
        sudo_remove_dir(texlive_root)
      end
    end
  end
  
  desc "Update LaTeX"
  task update: [:uninstall, :install]
end

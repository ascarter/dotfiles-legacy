#
# apm (atom package manager)
#

module APM
  def install(pkg)
    unless list().include?(pkg)
      system "apm install #{pkg}"
    else
      puts "#{pkg} already installed"
    end
  end
  module_function :install

  def upgrade
    system "apm upgrade --confirm false"
  end

  def uninstall(pkg)
    system "apm uninstall #{pkg}" if list().include?(pkg)
  end
  module_function :uninstall

  def list
    packages = []
    %x{apm list --installed --bare}.split.each do |p|
      (name, version) = p.split('@')
      packages.push(name)
    end
    return packages
  end
  module_function :list
end
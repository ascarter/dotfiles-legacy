#
# apm (atom package manager)
#

module APM
  module_function

  def install(pkg)
    if list.include?(pkg)
      puts "#{pkg} already installed"
    else
      system "apm install #{pkg}"
    end
  end

  def upgrade
    system 'apm upgrade --confirm false'
  end

  def uninstall(pkg)
    system "apm uninstall #{pkg}" if list.include?(pkg)
  end

  def list
    packages = []
    `apm list --installed --bare`.split.each do |p|
      (name, _version) = p.split('@')
      packages.push(name)
    end
    packages
  end
end

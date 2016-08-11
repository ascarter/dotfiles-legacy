# Gnome tasks

namespace 'gnome' do
  namespace 'terminal' do
    desc 'Export terminal settings'
    task :export do
      termdir = File.join(File.expand_path('terminal'), 'gnome')
      export_file = File.join(termdir, 'gnome-terminal-conf.xml')
      system "gconftool-2 --dump '/apps/gnome-terminal' > #{export_file}"
    end

    desc 'Import terminal settings'
    task :import do
      termdir = File.join(File.expand_path('terminal'), 'gnome')
      import_file = File.join(termdir, 'gnome-terminal-conf.xml')
      system "gconftool-2 --load #{import_file}"
    end
  end
end

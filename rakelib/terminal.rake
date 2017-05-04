# Terminal tasks

TERM_THEME_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', 'themes', 'terminal'))

namespace 'terminal' do
  namespace 'themes' do
    desc 'Install themes'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        srcdir = File.join(TERM_THEME_DIR, 'macos')
        Dir.glob(File.join(srcdir, '*.terminal')).each do |f|
          system "open #{f}"
        end
      end
    end
  end
end

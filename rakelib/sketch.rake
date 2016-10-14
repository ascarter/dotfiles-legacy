# sketch tasks

SKETCH_APP_NAME = 'Sketch'.freeze
SKETCH_SOURCE_URL = 'https://www.sketchapp.com/static/download/sketch.zip'.freeze

namespace 'sketch' do
  desc 'Install sketch'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(SKETCH_APP_NAME, SKETCH_SOURCE_URL)
    end
  end

  desc 'Uninstall sketch'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(SKETCH_APP_NAME)
    end
  end
end

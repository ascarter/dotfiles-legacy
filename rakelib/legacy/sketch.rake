# sketch tasks

SKETCH_APP_NAME = 'Sketch'.freeze
SKETCH_SOURCE_URL = 'https://download.sketchapp.com/sketch.zip'.freeze

SKETCH_PLUGINS = {
  'svgo-compressor-master/SVGO Compressor': 'https://github.com/BohemianCoding/svgo-compressor/archive/master.zip'.freeze,
  'Sketch Image Compressor': 'https://github.com/BohemianCoding/sketch-image-compressor/files/442132/sketch-image-compressor.zip'.freeze
}

namespace 'sketch' do
  desc 'Install sketch'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.install(SKETCH_APP_NAME, SKETCH_SOURCE_URL)
    end
  end

  desc 'Uninstall sketch'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.uninstall(SKETCH_APP_NAME)
    end
  end
  
  desc 'Install Sketch plugins'
  task :plugins do
    SKETCH_PLUGINS.each do |name, url|
      MacOS::Plugin.install("#{name}.sketchplugin", url)
    end
  end
end

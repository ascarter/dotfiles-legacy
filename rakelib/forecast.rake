FORECAST_APP_NAME = 'Forecast'.freeze
FORECAST_SOURCE_URL = 'https://d2uzvmey2c90kn.cloudfront.net/appcast_download/Forecast_0.9_122.zip'.freeze

namespace 'forecast' do
  desc 'About Forecast'
  task :about do
    Bootstrap.about('Forecast', 'Podcast MP3 Encoder with chapters', 'https://overcast.fm/forecast')
  end

  desc 'Install Forecast'
  task :install => [:about] do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(FORECAST_APP_NAME, FORECAST_SOURCE_URL)
    end
  end

  desc 'Uninstall FORECAST'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(FORECAST_APP_NAME)
    end
  end
end

# slack tasks

SLACK_APP_NAME = 'Slack'.freeze
SLACK_SOURCE_URL = 'https://slack.com/ssb/download-osx'.freeze

namespace 'slack' do
  desc 'Install Slack'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(SLACK_APP_NAME, SLACK_SOURCE_URL)
    end
  end

  desc 'Uninstall Slack'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(SLACK_APP_NAME)
    end
  end
end

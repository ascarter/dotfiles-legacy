# PostgreSQL

POSTGRES_APP_NAME = 'Postgres'.freeze
POSTGRES_SOURCE_URL = 'https://github.com/PostgresApp/PostgresApp/releases/download/9.6.1/Postgres-9.6.1.zip'.freeze

namespace 'postgres' do
  desc 'Install PostgreSQL'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(POSTGRES_APP_NAME, POSTGRES_SOURCE_URL)
    end
  end

  desc 'Uninstall PostgreSQL'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(POSTGRES_APP_NAME)
    end
  end

  desc 'Update PostgreSQL to latest version'
  task update: [:uninstall, :install]
end

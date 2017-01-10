# PostgreSQL

POSTGRES_APP_NAME = 'Postgres'.freeze
POSTGRES_SOURCE_URL = 'https://github.com/PostgresApp/PostgresApp/releases/download/v2.0.1/Postgres-2.0.1.dmg'.freeze

namespace 'postgres' do
  desc 'Install PostgreSQL'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(POSTGRES_APP_NAME, POSTGRES_SOURCE_URL)
      Bootstrap::MacOSX.path_helper('postgresapp', ['/Applications/Postgres.app/Contents/Versions/latest/bin'])
    end
  end

  desc 'Uninstall PostgreSQL'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(POSTGRES_APP_NAME)
      Bootstrap::MacOSX.rm_path_helper('postgresapp')
    end
  end

  desc 'Update PostgreSQL to latest version'
  task update: [:uninstall, :install]
end

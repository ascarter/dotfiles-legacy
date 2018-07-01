# PostgreSQL

POSTGRES_APP_NAME = 'Postgres'.freeze
POSTGRES_SOURCE_URL = 'https://github.com/PostgresApp/PostgresApp/releases/download/v2.0.1/Postgres-2.0.1.dmg'.freeze

PGADMIN_APP_NAME = 'pgAdmin 4'.freeze
PGADMIN_SOURCE_URL = 'https://ftp.postgresql.org/pub/pgadmin3/pgadmin4/v1.1/macos/pgadmin4-1.1.dmg'.freeze

namespace 'postgres' do
  desc 'Install PostgreSQL'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.install(POSTGRES_APP_NAME, POSTGRES_SOURCE_URL)
      MacOS.path_helper('postgresapp', ['/Applications/Postgres.app/Contents/Versions/latest/bin'])
    end
  end

  desc 'Uninstall PostgreSQL'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      MacOS::App.uninstall(POSTGRES_APP_NAME)
      MacOS.rm_path_helper('postgresapp')
    end
  end

  desc 'Update PostgreSQL to latest version'
  task update: [:uninstall, :install]

  namespace 'pgadmin' do
    desc 'Install pgAdmin'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        MacOS::App.install(PGADMIN_APP_NAME, PGADMIN_SOURCE_URL)
      end
    end

    desc 'Uninstall pgAdmin'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        MacOS::App.uninstall(PGADMIN_APP_NAME)
      end
    end
  end
end

# PostgreSQL

POSTGRES_APP_NAME = 'Postgres'
POSTGRES_SOURCE_URL = 'https://github.com/PostgresApp/PostgresApp/releases/download/9.5.2/Postgres-9.5.2.zip'

namespace "postgres" do
  desc "Install PostgreSQL"
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(POSTGRES_APP_NAME, POSTGRES_SOURCE_URL)
    end
  end

  desc "Uninstall PostgreSQL"
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(POSTGRES_APP_NAME)
    end
  end
end



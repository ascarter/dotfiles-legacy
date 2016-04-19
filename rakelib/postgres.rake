# PostgreSQL

namespace "postgres" do
  desc "Install PostgreSQL"
  task :install do
    if RUBY_PLATFORM =~ /darwin/      
      unless app_exists("Postgres")
        pkg_ver = '9.5.2'
        pkg_url = "https://github.com/PostgresApp/PostgresApp/releases/download/#{pkg_ver}/Postgres-#{pkg_ver}.zip"
        pkg_download(pkg_url) do |p|
          unzip(p)
          app_install(File.join(File.dirname(p), "Postgres.app"))
        end
      end
    end
  end

  desc "Uninstall PostgreSQL"
  task :uninstall do
    if RUBY_PLATFORM =~ /darwin/
      app_remove("Postgres")
    end
  end
end



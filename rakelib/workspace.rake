namespace 'workspace' do
  desc 'Init developer workspace'
  task :init do
    %w(bin pkg src).each do |d|
      p = File.join(Bootstrap.workspace_dir, d)
      unless File.exist?(p)
        puts "Initializing #{p}"
        FileUtils.mkdir_p(p)
      end

      # Add extra directories
      case d
      when "src"
        # Create scratch directories
        %w(go javascript ruby).each do |s|
          FileUtils.mkdir_p(File.join(p, 'scratch', s))
        end
      end
    end
  end

  task :readme do
    readme_path = File.join(Bootstrap.workspace_dir, 'README.md')
    unless File.exists?(readme_path)
      # Write projects README
      File.open(readme_path, 'w') do |f|
        f.write <<-EOF
# Development Projects Workspace

This is a workspace for software development projects. It uses the prescribed layout
for [Go](https://golang.org/doc/code.html#Workspaces). This layout is compatible with
other languages as well.

The following are the directories and their usage:

* `src` contains source code for projects
* `pkg` contains package objects (Go specific)
* `bin` contains executable commands and should be added to `PATH` environment variable

EOF
      end
    end
  end

  Rake::Task[:init].enhance do
    Rake::Task['workspace:readme'].invoke
  end

  desc 'Clean workspace'
  task :clean do
    ws = Bootstrap.workspace_dir
    if File.exist?(ws)
      puts "Cleaning workspace #{ws}"
      %w(bin pkg).each { |d| FileUtils.rm_rf(Dir.glob(File.join(ws, d, '*'))) }
    end
  end
end

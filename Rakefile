require 'rake'
require 'erb'

task :default => [ :install ]

desc "Install dotfiles to home directory using symlinks"
task :install do
  replace_all = false
  home = File.expand_path(ENV['HOME'])
  
  Dir['*'].each do |file|
    next if %w(Rakefile README.md).include?(file)
    filename = file.sub('.erb', '')
    target = File.expand_path(File.join(home, ".#{filename}"))
    if File.exist?(target) or File.symlink?(target) or File.directory?(target)
      if File.identical?(file, target)
        puts "Identical #{filename}"
      else
        if replace_all
          replace(file, target)
        else
          print "Replace existing file #{filename}? [ynaq] "
          case $stdin.gets.chomp
          when 'a'
            replace_all = true
            replace(file, target)
          when 'y'
            replace(file, target)
          when 'q'
            puts "Abort"
            exit
          else
            puts "Skipping #{filename}"
          end        
        end
      end
    else
      link(file, target)
    end
  end
end

def link(file, target)
  filename = file.sub('.erb', '')
  if file =~ /.erb$/
    puts "Generating #{filename}"
    File.open(target, 'w') do |output|
      output.write(ERB.new(File.read(file)).result(binding))
    end
  else
    puts "Symlink #{filename}"
    source = File.expand_path(File.join(File.dirname(__FILE__), file))
    File.symlink(source, target)
  end
end

def replace(file, target)
  backup = "#{target}.orig"
  puts "Backing up #{target} to #{backup}"
  File.rename(target, backup)
  link(file, target)
end

def prompt_for_value(message)
    print "Enter #{message}: "
    return $stdin.gets.chomp
end

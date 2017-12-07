namespace 'micro' do
  desc 'About micro'
  task :about do
    Bootstrap.about('micro', 'A modern and intuitive terminal-based text editor', 'https://micro-editor.github.io')
  end

  desc 'Install micro'
  task :install => [:about] do
    Bootstrap.sudo <<-CMD
      cd #{Bootstrap.usr_bin}; curl https://getmic.ro | sh
    CMD

    puts `#{Bootstrap.usr_bin_cmd 'micro'} -version`
  end

  desc 'Uninstall micro'
  task :uninstall do
    Bootstrap.usr_bin_rm 'micro'
  end
end

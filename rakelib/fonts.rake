# Font tasks

FONT_DIR = File.join(Bootstrap.home_dir, 'Library', 'Fonts')

namespace 'fonts' do
  task default: [:all]

  desc 'Install all fonts'
  task install: ['sfmono:install']

  desc 'Uninstall all fonts'
  task uninstall: ['sfmono:uninstall']

  #   desc "Adobe SourceCodePro"
  #   task :sourcecodepro do
  #     install_font('SourceCodePro', 'http://sourceforge.net/projects/sourcecodepro.adobe/files/latest/download')
  #   #!/bin/bash
  #   FONT_NAME="SourceCodePro"
  #   URL="http://sourceforge.net/projects/sourcecodepro.adobe/files/latest/download"
  #
  #   mkdir /tmp/adodefont
  #   cd /tmp/adodefont
  #   wget ${URL} -O ${FONT_NAME}.zip
  #   unzip -o -j ${FONT_NAME}.zip
  #   mkdir -p ~/.fonts
  #   cp *.otf ~/.fonts
  #   fc-cache -f -v
  #
  #   end

  namespace 'sfmono' do
    desc 'Install SF Mono (requires Xcode 8 or later)'
    task :install do
      src = '/Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Versions/A/Resources/Fonts/SFMono*.otf'
      Dir.glob(src).each { |f| FileUtils.cp(f, File.join(FONT_DIR, File.basename(f))) }
    end

    desc 'Uninstall SF mono'
    task :uninstall do
      src = File.join(FONT_DIR, 'SFMono*.otf')
      Dir.glob(src).each { |f| FileUtils.rm(f) }
    end
  end
end

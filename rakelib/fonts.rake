# Font tasks

FONT_DIR = File.join(Bootstrap.home_dir, 'Library', 'Fonts')

FONT_AWESOME_SOURCE_URL = 'http://fontawesome.io/assets/font-awesome-4.7.0.zip'.freeze
SFMONO_SOURCE_PATH = '/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SFMono*.otf'.freeze

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
      Dir.glob(SFMONO_SOURCE_PATH).each do |f|
        FileUtils.cp(f, File.join(FONT_DIR, File.basename(f)))
      end
    end

    desc 'Uninstall SF mono'
    task :uninstall do
      Bootstrap::MacOSX::Font.uninstall('SFMono*')
    end
  end

  namespace 'fontawesome' do
    desc 'Install FontAwesome'
    task :install do
      fontPath = File.join(File.basename(FONT_AWESOME_SOURCE_URL, '.zip'), 'fonts', 'FontAwesome')
      Bootstrap::MacOSX::Font.install(fontPath, FONT_AWESOME_SOURCE_URL)
    end

    desc 'Uninstall FontAwesome'
    task :uninstall do
      Bootstrap::MacOSX::Font.uninstall('FontAwesome')
    end
  end

end

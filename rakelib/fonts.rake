# Font tasks

FONT_DIR = File.join(Bootstrap.home_dir, 'Library', 'Fonts')

GOFONT_SOURCE_URL = 'https://go.googlesource.com/image/+archive/master/font/gofont/ttfs.tar.gz'.freeze
FONT_AWESOME_SOURCE_URL = 'http://fontawesome.io/assets/font-awesome-4.7.0.zip'.freeze
HACK_SOURCE_URL = 'https://github.com/chrissimpkins/Hack/releases/download/v2.020/Hack-v2_020-ttf.zip'.freeze

namespace 'fonts' do
  task default: [:all]

  desc 'Install all fonts'
  task install: ['sfmono:install', 'gofont:install', 'hack:install']

  desc 'Uninstall all fonts'
  task uninstall: ['sfmono:uninstall', 'gofont:uninstall', 'hack:uninstall']

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

  namespace 'gofont' do
    desc 'Install Go font'
    task :install do
      fontPath = File.join(File.basename(GOFONT_SOURCE_URL, '.tar.gz'))
      Bootstrap::MacOSX::Font.install('Go-*', GOFONT_SOURCE_URL, font_type: 'ttf')
    end

    desc 'Uninstall Go font'
    task :uninstall do
      Bootstrap::MacOSX::Font.uninstall('Go', font_type: 'ttf')
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

  namespace 'hack' do
    desc 'Install Hack font'
    task :install do
      Bootstrap::MacOSX::Font.install('Hack-*', HACK_SOURCE_URL, font_type: 'ttf')
    end

    desc 'Uninstall Hack font'
    task :uninstall do
      Bootstrap::MacOSX::Font.uninstall('Hack', font_type: 'ttf')
    end
  end
end

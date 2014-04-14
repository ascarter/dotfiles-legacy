# Font tasks

namespace "fonts" do
  task :default => [ :all ]

  desc "Install all fonts"
  task :all => [ :sourcecodepro ]

  desc "Adobe SourceCodePro"
  task :sourcecodepro do
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
  end
end

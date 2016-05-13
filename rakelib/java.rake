# Java JDK

JDK_PKG_NAME = 'JDK 8 Update 92'
JDK_PKG_IDS = %w{com.oracle.jdk8u92 com.oracle.jre}
JDK_SOURCE_URL = 'http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-macosx-x64.dmg'
JDK_DOWNLOAD_HEADERS = {
  'Cookie' => 'oraclelicense=accept-securebackup-cookie'
}

JDK_APPLE_PKG_NAME = 'JavaForOSX'
JDK_APPLE_PKG_IDS = %w{com.apple.pkg.JavaEssentials com.apple.pkg.JavaForMacOSX107 com.apple.pkg.JavaMDNS}
JDK_APPLE_SOURCE_URL = 'http://support.apple.com/downloads/DL1572/en_US/javaforosx.dmg'

namespace 'java' do
  desc 'Install Java JDK'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::Pkg.install(JDK_PKG_NAME, JDK_PKG_IDS[0], JDK_SOURCE_URL, headers: JDK_DOWNLOAD_HEADERS)
    end
    
    puts %x{java -version}
  end
  
  desc 'Uninstall Java JDK'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      JDK_PKG_IDS.each { |p| Bootstrap::MacOSX::Pkg.uninstall(p) }
    end
  end
  
  if Bootstrap.macosx?
    namespace 'apple' do
      desc 'Install legacy Apple JDK'
      task :install do
        Bootstrap::MacOSX::Pkg.install(JDK_APPLE_PKG_NAME, JDK_APPLE_PKG_IDS[0], JDK_APPLE_SOURCE_URL)
        puts %x{/usr/libexec/java_home -V}
      end
    
      desc 'Uninstall legacy Apple JDK'
      task :uninstall do
        JDK_APPLE_PKG_IDS.each { |p| Bootstrap::MacOSX::Pkg.uninstall(p) }
      end
    end
  end
end

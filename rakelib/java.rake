# Java JDK

JDK_PKG_NAME = 'JDK 8 Update 101'.freeze
JDK_PKG_IDS = %w(com.oracle.jdk8u101 com.oracle.jre).freeze
JDK_SOURCE_URL = 'http://download.oracle.com/otn-pub/java/jdk/8u101-b13/jdk-8u101-macosx-x64.dmg'.freeze
JDK_DOWNLOAD_HEADERS = {
  'Cookie' => 'oraclelicense=accept-securebackup-cookie'
}.freeze

JDK_APPLE_PKG_NAME = 'JavaForOSX'.freeze
JDK_APPLE_PKG_IDS = %w(com.apple.pkg.JavaEssentials com.apple.pkg.JavaForMacOSX107 com.apple.pkg.JavaMDNS).freeze
JDK_APPLE_SOURCE_URL = 'http://support.apple.com/downloads/DL1572/en_US/javaforosx.dmg'.freeze

namespace 'java' do
  desc 'Install Java'
  task install: ['jdk:install']

  desc 'Uninstall Java'
  task uninstall: ['jdk:uninstall']

  if Bootstrap.macosx?
    task install: ['apple:install']
    task uninstall: ['apple:uninstall']
  end

  namespace 'jdk' do
    desc 'Install Java JDK'
    task :install do
      case RUBY_PLATFORM
      when /darwin/
        Bootstrap::MacOSX::Pkg.install(JDK_PKG_NAME, JDK_PKG_IDS[0], JDK_SOURCE_URL, headers: JDK_DOWNLOAD_HEADERS)
      end

      puts `java -version`
    end

    desc 'Uninstall Java JDK'
    task :uninstall do
      case RUBY_PLATFORM
      when /darwin/
        JDK_PKG_IDS.each { |p| Bootstrap::MacOSX::Pkg.uninstall(p) }
      end
    end
  end

  if Bootstrap.macosx?
    namespace 'apple' do
      desc 'Install legacy Apple JDK'
      task :install do
        Bootstrap::MacOSX::Pkg.install(JDK_APPLE_PKG_NAME, JDK_APPLE_PKG_IDS[0], JDK_APPLE_SOURCE_URL)
        puts `/usr/libexec/java_home -V`
      end

      desc 'Uninstall legacy Apple JDK'
      task :uninstall do
        JDK_APPLE_PKG_IDS.each { |p| Bootstrap::MacOSX::Pkg.uninstall(p) }
      end
    end
  end
end

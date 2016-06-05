# tex tasks

TEX_PKG_NAME = 'mactex-20160603'
TEX_PKG_ID = 'org.mactex'
TEX_SOURCE_URL = 'http://tug.org/cgi-bin/mactex-download/MacTeX.pkg'

namespace 'tex' do
	desc 'Install tex'
	task :install do
	  case RUBY_PLATFORM
	  when /darwin/
  		Bootstrap::MacOSX::Pkg.install(TEX_PKG_NAME, TEX_PKG_ID, TEX_SOURCE_URL)
  	end
  	
  	puts %x{texdist --current}
	end
	
	desc 'Uninstall tex'
	task :uninstall do
	  case RUBY_PLATFORM
	  when /darwin/
  		Bootstrap::MacOSX::Pkg.uninstall(TEX_PKG_ID)
  	end
	end	
end

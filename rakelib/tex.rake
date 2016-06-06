# tex tasks

TEX_PKG_NAME = 'mactex-20160603'
TEX_PKG_IDS = [
  'org.tug.mactex.texlive2016',
  'org.tug.mactex.gui2016',
  'org.tug.mactex.ghostscript9.19',
]

TEX_SOURCE_URL = 'http://tug.org/cgi-bin/mactex-download/MacTeX.pkg'

namespace 'tex' do
	desc 'Install tex'
	task :install do
	  case RUBY_PLATFORM
	  when /darwin/
  		Bootstrap::MacOSX::Pkg.install(TEX_PKG_NAME, TEX_PKG_IDS[0], TEX_SOURCE_URL)
  	end
  	
  	puts %x{texdist --current}
	end
	
	desc 'Uninstall tex'
	task :uninstall do
	  case RUBY_PLATFORM
	  when /darwin/
	    TEX_PKG_IDS.each { |p| Bootstrap::MacOSX::Pkg.uninstall(p) }
  	end
	end	
end

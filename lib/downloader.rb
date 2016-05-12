#
# Downloader
#

module Bootstrap
  # Download source to dest directory following redirects up to limit
  # Returns downloaded file
  def download(src, dest, limit=10)
    raise "Too many redirects" if limit == 0
    uri = URI(src)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      http.request request do |response|
        puts "response: #{response.to_hash.inspect}"
        case response
        when Net::HTTPSuccess then
          filename = File.basename(src)
          unless %{.zip .dmg .pkg}.include?(File.extname(filename))
            filename = /.*filename="?([^\";]*)"?/ni.match(response['content-disposition'])[1]
            content_type = response.sub_type()
        
            if filename.nil?
              case content_type
              when 'application/zip'
                filename = 'pkg.zip'
              when 'application/x-apple-diskimage'
                filename = 'pkg.dmg'
              else
                raise "Unsupported content-type: #{content_type}"
              end
            end
          end
          
          target = File.join(dest, filename)
          thread = start_thread(response, target)
          
          print "\rDownloading #{filename}: %d%%" % thread[:progress].to_i until thread.join(1)
          print "\rDownloading #{filename}: done"
          puts ""
          return target
        when Net::HTTPRedirection then
          # Replace spaces
          location = response['location'].gsub(/ /, '%20')
          warn "  --> redirected to #{location}"
          return download(location, dest, limit - 1)
        else
          raise "#{response.class.name} #{response.code} #{response.message}"
        end
      end
    end
  end
  module_function :download

  def download_to_tempdir(src, limit=10)
    uri = URI.parse(src)
    (path, pkg) = File.split(uri.path)
    Dir.mktmpdir { |d| yield download(src, d, limit) }
  end
  module_function :download_to_tempdir

  def download_with_extract(src)
    puts "Requesting #{src}"
    download_to_tempdir(src) do |p|
      puts "Extracting #{p}"
      ext = File.extname(p)
      case ext
      when ".zip"
        unzip(p) { |d| yield d }
      when ".dmg"
        mount_dmg(p) { |d| yield d }
      when ".pkg"
        yield File.dirname(p)
      else
        raise "Download package format #{ext} not supported"
      end
    end
  end
  module_function :download_with_extract

  def unzip(zipfile, exdir=nil)
    exdir = File.dirname(zipfile) if exdir.nil?
    system "unzip -q #{zipfile} -d #{exdir}"
    yield exdir
  end
  module_function :unzip

  def mount_dmg(dmg)
    d = %x{hdiutil attach "#{dmg}" | tail -1 | awk '{$1=$2=""; print $0}' | xargs -0 echo}.strip!
    yield d
    system "hdiutil detach \"#{d}\""
  end
  module_function :mount_dmg

  def start_thread(response, dest)
    Thread.new do
      thread = Thread.current
      length = thread[:length] = response['Content-Length'].to_i
      open(dest, 'wb') do |io|
        response.read_body do |fragment|
          thread[:done] = (thread[:done] || 0) + fragment.length
          thread[:progress] = thread[:done].quo(length) * 100
          io.write fragment
        end
      end
    end
  end
  module_function :start_thread
  private_class_method :start_thread
end

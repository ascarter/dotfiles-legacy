module Bootstrap
  # Downloader provides helpers for downloading resources
  module Downloader
    # Download source to dest directory following redirects up to limit
    # Returns downloaded file
    def download(src, dest, headers: {}, limit: 10, sig: {})
      raise 'Too many redirects' if limit.zero?
      uri = URI(src)
      Net::HTTP.start(uri.host,
                      uri.port,
                      use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        headers.each { |k, v| request[k] = v }
        http.request request do |response|
          case response
          when Net::HTTPSuccess then
            case File.extname(uri.path)
            when '.zip', '.dmg', '.pkg', '.tar.gz', '.safariextz'
              filename = File.basename(uri.path)
            when '.html'
              system "open #{src}"
              raise 'Download failed'
            else
              content_type = response.sub_type
              content_disposition = response['content-disposition']
              mdata = /.*filename="?([^\";]*)"?/ni.match(content_disposition)
              filename = mdata[1] if mdata
              if filename.nil?
                case content_type
                when 'application/zip'
                  filename = 'pkg.zip'
                when 'application/x-apple-diskimage'
                  filename = 'pkg.dmg'
                when 'application/x-gzip'
                  filename = 'pkg.gz'
                when 'plain'
                  filename = File.basename(uri.path)
                else
                  raise "Unsupported content-type: #{content_type}"
                end
              end
            end

            target = File.join(dest, filename)
            thread = start_thread(response, target)

            print "\rDownloading #{filename}: #{thread[:progress].to_i}%" until thread.join(1)
            print "\rDownloading #{filename}: done"
            puts ''

            verify_signature(sig, target)
            puts 'Package has valid signature'
            return target
          when Net::HTTPRedirection then
            # Replace spaces
            location = response['location'].gsub(/ /, '%20')
            warn "  --> redirected to #{location}"
            return download(location, dest, headers: headers, limit: limit - 1)
          else
            raise "#{response.class.name} #{response.code} #{response.message}"
          end
        end
      end
    end
    module_function :download

    def download_to_tempdir(src, headers: {}, limit: 10, sig: {})
      Dir.mktmpdir do |d|
        yield download(src, d, headers: headers, limit: limit, sig: sig)
      end
    end
    module_function :download_to_tempdir

    def download_with_extract(src, headers: {}, limit: 10, sig: {})
      puts "Requesting #{src}"
      download_to_tempdir(src, headers: headers, limit: limit, sig: sig) do |p|
        puts "Extracting #{p}"
        ext = File.extname(p)
        case ext
        when '.zip'
          unzip(p) { |d| yield d }
        when '.gz'
          gunzip(p) { |d| yield d }
        when '.dmg'
          mount_dmg(p) { |d| yield d }
        when '.pkg', '.safariextz'
          yield File.dirname(p)
        else
          raise "Download package format #{ext} not supported"
        end
      end
    end
    module_function :download_with_extract

    def unzip(zipfile, exdir: nil)
      exdir = File.dirname(zipfile) if exdir.nil?
      system "unzip -q #{zipfile} -d #{exdir}"
      yield exdir
    end
    module_function :unzip

    def gunzip(gzipfile, exdir: nil)
      exdir = File.dirname(gzipfile) if exdir.nil?
      FileUtils.mkdir_p(exdir)
      system "cd #{exdir} && gunzip -q #{gzipfile}"
      p = File.basename(gzipfile, ".gz")
      case File.extname(p)
      when '.tar'
        untar(p, exdir: exdir) { |d| yield d }
      else
        yield exdir
      end
    end
    module_function :gunzip

    def untar(tarfile, exdir: nil)
      exdir = File.dirname(tarfile) if exdir.nil?
      FileUtils.mkdir_p(exdir)
      system "tar -x -f #{File.join(exdir, tarfile)} -C #{exdir}"
      yield exdir
    end
    module_function :untar

    def mount_dmg(dmg)
      # hdiutil attach returns:
      # /dev node, a tab, content hint (if applicable), another tab, mount point
      # Split on tabs and use the last as the mount point
      d = `hdiutil attach "#{dmg}" | tail -1`.split("\t")[-1].strip
      puts "Mount #{dmg} to #{d}"
      yield d
      system "hdiutil detach \"#{d}\""
    end
    module_function :mount_dmg

    def start_thread(response, dest)
      Thread.new do
        thread = Thread.current
        if response.key?('Content-Length')
          length = thread[:length] = response['Content-Length'].to_i
          raise 'No content' if length.zero?
        end
        open(dest, 'wb') do |io|
          response.read_body do |fragment|
            thread[:done] = (thread[:done] || 0) + fragment.length
            # Show progress only if repsonse provides content length
            if response.key?('Content-Length')
              thread[:progress] = thread[:done].quo(length) * 100
            end
            io.write fragment
          end
        end
      end
    end
    module_function :start_thread
    private_class_method :start_thread

    def verify_signature(sig, target)
      sig.each do |k, v|
        case k
        when :md5
          raise 'Invalid md5 for package' if v != Bootstrap.md5(target)
        when :sha1
          raise 'Invalid sha1 for package' if v != Bootstrap.sha1(target)
        when :sha2
          raise 'Invalid sha2 for package' if v != Bootstrap.sha2(target)
        else
          raise "Unknown signature: #{k}"
        end
      end
    end
    module_function :verify_signature
    private_class_method :verify_signature
  end
end

module SANDBOX
  class HttpRuntime
    USER_AGENT = "mruby_sandbox"
    def request(options = {})
      opts = options || {}
      if options.is_a? String 
        opts = { :url => options }
      end

      if opts[:url].blank?
        return { :statuscode => 0, :err => "url is required" }
      end

      opts[:headers] ||= {}
      opts[:method] ||= "GET"
      opts[:method] = opts[:method].upcase.to_s

      parser = HTTP::Parser.new()
      url = parser.parse_url(opts[:url])
      host = url[:host].to_sym.to_s
      request_uri = url[:path]
      if url[:query]
          request_uri += "?" + url[:query]
      end

      opts.headers[:"User-Agent"]    = USER_AGENT

      if opts[:data]
        opts[:body] = opts[:data].is_a?(Hash) ? self.qsencode(opts[:data]) : opts[:data].to_s
        opts[:"Content-Length"] = (opts[:body] || '').length
      end

      SimpleHttp.new(url.schema, host, url.port).request(opts.method, request_uri, request)
    end

    def qsencode(params, delimiter = '&', quote = nil)
      if params.is_a?(Hash)
        params = params.map do |key, value|
          sprintf("%s=%s%s%s", escape(key.to_s), quote, escape(value.to_s), quote)
        end
      else
        params = params.map { |value| HTTP::URL::encode(value) }
      end
      delimiter ? params.join(delimiter) : params
    end

    def qsdecode(qs)
      hashes = qs.split('&').inject({}) do |result,query| 
        k,v = query.split('=')
        result.merge(HTTP::URL::decode(k).to_sym => HTTP::URL::decode(v))
      end
      hashes
    end

    def escape(str)
      reserved_str = [
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "n", "m", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", 
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "-", ".", "_", "~"
      ]
      tmp = ''
      str = str.to_s
      str.size.times do |idx|
        chr = str[idx]
        if reserved_str.include?(chr)
          tmp += chr
        else
          tmp += "%" + chr.unpack("H*").first.upcase
        end
      end
      #puts "#{str}: #{tmp}"
      tmp
    end
  end
end
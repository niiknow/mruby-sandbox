module SANDBOX
  class HttpRuntime
    def request(options = {})
      opts = options || {}
      if options.is_a? String 
        opts = { :url => options }
      end
      if opts.url.blank?
        return { :statuscode => 0, :err => "url is required" }
      end

      opts.headers ||= {}
      opts.method ||= "GET"
      opts.method = opts.method.upcase.to_s

      if opts.data
        opts["body"] = opts.data.is_a?(Hash) ? self.qsencode(opts.data) : opts.data.to_s
        opts["Content-Length"] = (opts["body"] || '').length
      end

      # do http call
    end

    def qsencode(params, delimiter = '&', quote = nil)
      if params.is_a?(Hash)
        params = params.map do |key, value|
          sprintf("%s=%s%s%s", HTTP::URL::encode(key), quote, HTTP::URL::encode(value), quote)
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
  end
end
module SANDBOX
  class HttpRuntime
    USER_AGENT = "Mozilla/5.0"

    # 
    # make a request
    # @param options = {} [Hash] url, method, data, params, auth, oauth, headers
    # 
    # @return [Hash] content, statuscode, headers
    def request(options = {})
      opts = options || {}
      if options.is_a? String 
        opts = { "url" => options }
      end

      if opts["url"].nil?
        return { "statuscode" => 0, "err" => "url is required" }
      end
      begin
        parser = HTTP::Parser.new()
        url = parser.parse_url(opts["url"])
        host = url.host.to_sym.to_s
        request_uri = url.path
        if url.query
            request_uri += "?" + url.query
        end

        opts["urlParsed"] = url
        opts["headers"] ||= {}
        opts["method"] ||= "GET"
        opts["method"] = opts["method"].upcase.to_s
        opts["headers"]["User-Agent"]    = USER_AGENT

        if opts["data"]
          opts["body"] = opts["data"].is_a?(Hash) ? self.qsencode(opts["data"]) : opts["data"].to_s
          opts["Content-Length"] = (opts["body"] || '').length
        end

        authHeader(opts)
        
        rsp = SimpleHttp.new(url.schema, host, url.port).request(opts["method"], request_uri, opts["headers"])

        {"content" => rsp.body, "statuscode" => rsp.code, "headers" => rsp.headers, "req" => opts, "rsp" => rsp}
      rescue Exception => e
        {"statuscode" => 0, "err" => e, "req" => opts}
      end
    end

    # 
    # query string encode
    # @param params [Hash] encoding quey string
    # @param delimiter = '&' [String] separator
    # @param quote = nil [String] quote character around value
    # 
    # @return [String] the encoded query string
    def qsencode(params, delimiter = '&', quote = nil)
      if params.is_a?(Hash)
        params = params.map do |key, value|
          sprintf("%s=%s%s%s", encodeURIComponent(key.to_s), quote, encodeURIComponent(value.to_s), quote)
        end
      else
        params = params.map { |value| HTTP::URL::encode(value) }
      end
      delimiter ? params.join(delimiter) : params
    end


    # 
    # decode query string into a hash
    # @param qs [String] string ot decode
    # 
    # @return [Hash] result object
    def qsdecode(qs)
      qs.split('&').inject({}) do |result,query| 
        k,v = query.split('=')
        result.merge(HTTP::URL::decode(k) => HTTP::URL::decode(v))
      end
    end

    # 
    # random for use as nonce or state query string
    # 
    # @return [String] some random hex
    def nonce() 
      Digest::MD5.hexdigest(Time.now.to_i.to_s)
    end
private
    # 
    # encodeURIComponent 
    # @param str [String] string to decode
    # 
    # @return [String] the URI encoded string
    def encodeURIComponent(str)
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

    # 
    # create auth header if defined
    # @param opts [Object] request parameters
    # 
    # @return [Object] self
    def authHeader(opts)
      auth = opts["auth"]
      if opts["auth"]
        if auth["oauth"]
          return oauthHeader(opts)
        end
        cred = util.base64("#{auth[0]}:#{auth[1]}")
        opts.headers["Authorization"] = "Basic #{cred}"
      end
      self
    end

    # 
    # apply oauth header if defined
    # @param opts [Object] request parameters 
    # 
    # @return [Object] self
    def oauthHeader(opts)
      oauth = opts["auth"]["oauth"]
      if oauth
        timestamp = Time.now.to_i.to_s
        parameters = {
          "oauth_consumer_key" => oauth["consumerkey"],
          "oauth_token" => oauth["accesstoken"],
          "oauth_signature_method" => "HMAC-SHA1",
          "oauth_timestamp" => timestamp,
          "oauth_nonce" => nonce,
          "oauth_version" => oauth["version"] || '1.0'
        }

        if (oauth["accesstoken"])
          parameters["oauth_token"] = oauth["accesstoken"]
        end

        if (oauth["callback"])
          parameters["oauth_callback"] = encodeURIComponent(oauth["callback"])
        end

        parameters["oauth_signature"] = signature(opts, parameters)
        opts["headers"]["Authorization"] = "OAuth #{qsencode(parameters, ',', '"')}"
      end
      self
    end

    # 
    # generate signature
    # @param opts [Object] request parameter
    # @param parameters [Object] oauth parameters
    # 
    # @return [String] the signature
    def signature(opts, parameters)
      util = UtilRuntime. new
      util.base64(util.digest_hmac_sha1(calculateBaseString(opts["method"], opts["urlParsed"], opts["body"], parameters), secret(opts["auth"])))
    end

    # 
    # generate secret key for signing
    # @param auth [Object] the oauth config
    # 
    # @return [String] the secret to use for signing
    def secret(auth)
      oauth = auth["oauth"]
      encodeURIComponent(oauth["consumersecret"]) + '&' + encodeURIComponent(oauth["tokensecret"] || '')
    end

    # 
    # calculate the base string to sign with
    # @param method [String] http method
    # @param url [Object] the parsed url that includes query string
    # @param body [string] the content to send
    # @param parameters [Object] the signature parameter
    # 
    # @return [String] the result base string
    def calculateBaseString(method, url, body, parameters)
      base_url = calculateBaseUrl(url)
      parameters = normalizeParameters(parameters, body, url.query)
      qsencode([ method, base_url, parameters ])
    end

    # 
    # calculate the base url from parsed url
    # @param url [Object] the parsed URL
    # 
    # @return [String] the base URL string
    def calculateBaseUrl(url)
      str = url.schema + "://"
      str += url.host
      str += ":" + url.port.to_s  if url.port
      str += url.path if url.path
      str
    end

    # 
    # create the result string for signature
    # @param parameters [Object] the oauth parameters
    # @param body [String] the content to send
    # @param query [String] the query string
    # 
    # @return [String] the result string without signature
    def normalizeParameters(parameters, body, query)
      parameters = qsencode(parameters, nil)
      parameters += body.split('&') if body
      parameters += query.split('&') if query
      parameters.sort.join('&')
    end
  end
end
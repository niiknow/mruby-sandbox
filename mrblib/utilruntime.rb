module SANDBOX
  class UtilRuntime
  	def base64(value)
      r = [ value ].pack('m')
      r.include?("\n") ? r.split("\n").join("") : r
    end

    def digest_hmac_sha1(value, secret)
      Digest::HMAC.digest(value, secret, Digest::SHA1)
    end

    def digest_hex_sha256(value)
      Digest::SHA256.new.update(value).hexdigest
    end

    def digest_hmac_sha256(key, value)
      Digest::HMAC.digest(value, key, Digest::SHA256)
    end

    def digest_hmac_hex_sha256(key, value)
      Digest::HMAC.hexdigest(value, key, Digest::SHA256)
	end
  end
end
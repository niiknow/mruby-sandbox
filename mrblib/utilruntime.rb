module SANDBOX
  class UtilRuntime
  	def base64(value)
      r = [ value ].pack('m')
      r.include?("\n") ? r.split("\n").join("") : r
    end

    def digest_hmac_sha1(value, secret)
      Digest::HMAC.digest(value, secret, Digest::SHA1)
    end
  end
end
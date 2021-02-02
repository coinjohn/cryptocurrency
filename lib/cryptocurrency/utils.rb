require 'digest'

module Cryptocurrency
  module Utils
    class << self
      def ripemd160(data)
        Digest::RMD160.digest(data)
      end

      def sha256(data)
        Digest::SHA2.new(256).digest(data)
      end

      def double_sha256(data)
        sha256(sha256(data))
      end

      def hash160(data)
        ripemd160(sha256(data))
      end

      def hmac_sha512(key, data)
        digest = OpenSSL::Digest.new('sha512')
        OpenSSL::HMAC.digest(digest, key, data)
      end

      def bech32_encode(hrp, data)
        Bech32.encode(hrp, data)
      end

      def bech32_decode(data)
        Bech32.decode(data)
      end

      def bytes_to_integer(bytes)
        bytes.unpack1('H*').to_i(16)
      end

      def integer_to_bytes(integer)
        hex = integer.to_s(16)
        hex = "0#{hex}" if hex.length.odd?
        [hex].pack('H*')
      end
    end
  end
end

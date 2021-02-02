require_relative './utils'

module Cryptocurrency
  class Base58
    ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'.freeze

    def self.encode58(data)
      return '' if data.empty?

      n = Utils.bytes_to_integer(data)

      b58_bytes = []
      while n > 0
        b58_bytes << n % 58
        n /= 58
      end

      zeroes = data.bytes.find_index { |b| b != 0 } || data.length
      '1' * zeroes + b58_bytes.map do |v|
        ALPHABET[v]
      end.join.reverse
    end

    def self.decode58(data)
      prefix = ''
      in_prefix = true

      value = 0

      data.chars.each do |ch|
        if ch == '1' && in_prefix
          prefix += "\x00"
        else
          in_prefix = false

          n = ALPHABET.index(ch)
          value = (value * 58) + n
        end
      end

      prefix + Utils.integer_to_bytes(value)
    end

    def self.encode58_check(data)
      checksum = Utils.double_sha256(data)[0...4]
      encode58(data + checksum)
    end

    def self.decode58_check(data)
      bin = decode58(data)
      value = bin[0...-4]
      checksum = bin[-4..]

      return unless checksum == Utils.double_sha256(value)[0...4]

      value
    end
  end
end

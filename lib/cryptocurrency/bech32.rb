module Cryptocurrency
  module Bech32
    SEPARATOR = '1'.freeze
    CHARSET = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l'.freeze

    class << self
      # Encode Bech32 string
      def encode(hrp, data)
        blocks = split_5bits(data)

        checksummed = blocks + create_checksum(hrp, blocks)
        hrp + SEPARATOR + checksummed.map { |i| CHARSET[i] }.join
      end

      # Decode a Bech32 string and determine hrp and data
      def decode(bech)
        # check invalid bytes
        return nil if bech.scrub('?').include?('?')

        # check uppercase/lowercase
        return nil if bech.downcase != bech && bech.upcase != bech

        bech.each_char { |c| return nil if c.ord < 33 || c.ord > 126 }
        bech = bech.downcase

        # check data length
        pos = bech.rindex(SEPARATOR)
        return nil if pos.nil? || pos < 1 || pos + 7 > bech.length || bech.length > 90

        # check valid charset
        bech[pos + 1..-1].each_char { |c| return nil unless CHARSET.include?(c) }

        # split hrp and data
        hrp = bech[0..pos - 1]
        data = bech[pos + 1..-1].each_char.map { |c| CHARSET.index(c) }

        # check checksum
        return nil unless verify_checksum(hrp, data)

        [hrp, join_5bits(data[0..-7])]
      end

      # Compute the checksum values given hrp and data.
      def create_checksum(hrp, data)
        values = expand_hrp(hrp) + data
        polymod = polymod(values + [0, 0, 0, 0, 0, 0]) ^ 1
        (0..5).map { |i| (polymod >> 5 * (5 - i)) & 31 }
      end

      # Verify a checksum given Bech32 string
      def verify_checksum(hrp, data)
        polymod(expand_hrp(hrp) + data) == 1
      end

      def split_5bits(data)
        n = Utils.bytes_to_integer(data)

        chunks = []
        while n > 0
          chunks << n % 32
          n /= 32
        end

        zeroes = data.bytes.find_index { |b| b != 0 } || data.length

        [0] * zeroes + chunks.reverse
      end

      def join_5bits(data)
        n = 0
        in_prefix = true
        prefix = ''

        data.each do |i|
          if in_prefix && i == 0
            prefix += "\x00"
          else
            in_prefix = false
          end

          n = n * 32 + i
        end

        prefix + Utils.integer_to_bytes(n)
      end

      private

      # Expand the hrp into values for checksum computation.
      def expand_hrp(hrp)
        hrp.each_char.map { |c| c.ord >> 5 } + [0] + hrp.each_char.map { |c| c.ord & 31 }
      end

      # Compute Bech32 checksum
      def polymod(values)
        generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
        chk = 1
        values.each do |v|
          top = chk >> 25
          chk = (chk & 0x1ffffff) << 5 ^ v
          (0..4).each { |i| chk ^= ((top >> i) & 1) == 0 ? 0 : generator[i] }
        end
        chk
      end
    end
  end
end

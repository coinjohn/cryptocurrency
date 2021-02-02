module Cryptocurrency
  module Address
    def self.for(public_key, currency, kind = :p2pkh)
      case kind
      when :p2pkh
        data = version(currency, kind) + hash(public_key, :bitcoin)
        Base58.encode58_check(data)
      when :segwit
        script = "\x00\x14" + hash(public_key, :bitcoin)
        data = version(currency, :p2sh) + Utils.hash160(script)
        Base58.encode58_check(data)
      when :segwit_native
        Bech32.encode(BECH_PREFIXES[currency], "\x00" + hash(public_key, :bitcoin))
      end
    end

    def self.hash(public_key, kind = :bitcoin)
      case kind
      when :bitcoin
        Utils.hash160(public_key.to_octet_stream(:compressed))
      when :ethereum
        Utils.kekkak(public_key.to_octet_stream(:uncompressed))[-20..]
      end
    end

    BECH_PREFIXES = {
      btc: 'bc',
      tbtc: 'tc',
      rtbtc: 'bcrt',
      ltc: 'ltc',
      tltc: 'tltc'
    }.freeze

    PREFIXES = {
      btc: {
        p2pkh: "\x00",
        p2sh: "\x05"
      },
      ltc: {
        p2pkh: "\x30",
        p2sh: "\x32"
      },
      doge: {
        p2pkh: "\x1e",
        p2sh: "\x16"
      },
      tbtc: {
        p2pkh: "\x6f",
        p2sh: "\xc4".force_encoding('BINARY')
      },
      rtbtc: {
        p2pkh: "\x6f",
        p2sh: "\xc4".force_encoding('BINARY')
      },
      tltc: {
        p2pkh: "\x6f",
        p2sh: "\x3a"
      },
      tdoge: {
        p2pkh: "\x71",
        p2sh: "\xc4"
      }
    }.freeze

    def self.version(currency, type)
      PREFIXES[currency][type]
    end
  end
end

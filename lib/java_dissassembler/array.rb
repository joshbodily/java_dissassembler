class Array
  def u2
    self.pack("C*").unpack("s>").first
  end

  def u4
    self.pack("C*").unpack("N").first
  end

  def modified_utf8_to_s
    new_str = ""
    bytes = self
    until bytes.empty?
      # Code points in the range '\u0001' to '\u007F' are represented by a single byte
      if (bytes[0] >> 7) == 0
        new_str << bytes[0]
        bytes.shift
      # The null code point ('\u0000') and code points in the range '\u0080' to '\u07FF' are represented by a pair of bytes x and y
      elsif (bytes[0] >> 5) == 0b110
        new_str << [((bytes[0] & 0x1f) << 6) + (bytes[1] & 0x3f)].pack("U")
        bytes.shift(2)
      # Code points in the range '\u0800' to '\uFFFF' are represented by 3 bytes
      elsif ((bytes[0] >> 4) == 0b1110) && (bytes[0] != 0b11101101)
        new_str << [((bytes[0] & 0xf) << 12) + ((bytes[1] & 0x3f) << 6) + (bytes[2] & 0x3f)].pack("U")
        bytes.shift(3)
      # Characters with code points above U+FFFF (so-called supplementary characters) are represented by separately encoding the
      # two surrogate code units of their UTF-16 representation
      elsif (bytes[0] == 0b11101101) && (bytes[3] == 0b11101101)
        new_str << [0x10000 + ((bytes[1] & 0x0f) << 16) + ((bytes[2] & 0x3f) << 10) + ((bytes[4] & 0x0f) << 6) + (bytes[5] & 0x3f)].pack("U")
        bytes.shift(6)
      else
        raise "Invalid \"Modified\" UTF-8 byte `#{bytes[0]}'"
      end
    end
    new_str
  end
end

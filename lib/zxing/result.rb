module ZXing
  class Result
    attr_reader :barcode_format, :text

    def initialize(barcode_format, text)
      @barcode_format = barcode_format
      @text = text
    end

    def ==(other)
      self.class == other.class && (text == other.text) && (barcode_format == other.barcode_format)
    end
    alias_method :eql?, :==
  end
end

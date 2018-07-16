require 'uri'

module ZXing
  if RUBY_PLATFORM != 'java'
    require 'zxing/client'
  else
    require 'java'
    require 'zxing/core-3.3.0.jar'
    require 'zxing/javase-3.3.0.jar'

    java_import com.google.zxing.MultiFormatReader
    java_import com.google.zxing.qrcode.QRCodeReader
    java_import com.google.zxing.BinaryBitmap
    java_import com.google.zxing.Binarizer
    java_import com.google.zxing.common.GlobalHistogramBinarizer
    java_import com.google.zxing.common.HybridBinarizer
    java_import com.google.zxing.LuminanceSource
    java_import com.google.zxing.client.j2se.BufferedImageLuminanceSource
    java_import com.google.zxing.multi.GenericMultipleBarcodeReader
    # The below allows removing this deprecation:
    # lib/zxing/decoder.rb:28: warning: constant ::NativeException is deprecated
    java_import com.google.zxing.NotFoundException # Is this how to do tht?
    java_import com.google.zxing.FormatException
    java_import com.google.zxing.DecodeHintType
    java_import com.google.zxing.BarcodeFormat
    java_import com.google.zxing.oned.MultiFormatOneDReader

    java_import javax.imageio.ImageIO
    java_import java.net.URL
    java_import java.util.HashMap

    class Decoder
      attr_accessor :file

      def self.decode!(file)
        new(file).decode
      rescue NotFoundException, FormatException
        raise UndecodableError
      rescue ArgumentError => e
        raise e
      rescue NativeException => e
        $stderr.puts "#{e.class}: #{e.message}"
        $stderr.puts e.backtrace
        raise e
      end

      def self.decode(file)
        decode!(file)
      rescue UndecodableError
        nil
      end

      def self.decode_all!(file)
        new(file).decode_all
      rescue NotFoundException, FormatException
        raise UndecodableError
      rescue ArgumentError => e
        raise e
      rescue NativeException => e
        $stderr.puts "#{e.class}: #{e.message}"
        raise e
      end

      def self.decode_all(file)
        decode_all!(file)
      rescue UndecodableError
        []
      end

      def self.qrcode_decode(file)
        new(file).qrcode_decode
      end

      def initialize(file)
        self.file = file
      end

      def reader
        MultiFormatReader.new
      end

      # Enum access? https://stackoverflow.com/questions/33610873/access-enums-from-jar-file-in-jruby
      # Other hints to try in the future:
      # 1) hints.put(DecodeHintType::ASSUME_GS1, true)
      # Other readers to try in the future:
      # 1) MultiFormatOneDReader.new(hints)
      # reader.decode returns https://zxing.github.io/zxing/apidocs/com/google/zxing/Result.html
      # @return [ZXing::Result]
      def decode
        hints = HashMap.new
        hints.put(DecodeHintType::TRY_HARDER, true)
        scan_result = reader.decode(bitmap, hints) || reader.decode(hybrid_bitmap, hints)
        barcode_format = barcode_format_to_sym(scan_result.get_barcode_format)
        $stderr.puts("Rich class #{barcode_format} #{scan_result.get_text}")
        Result.new(barcode_format, scan_result.get_text)
      end

      def qrcode_decode
        qr_decode(bitmap) || qr_decode(hybrid_bitmap)
      end

      # @return [Array<ZXing::Result>]
      def decode_all
        hints = HashMap.new
        hints.put(DecodeHintType::TRY_HARDER, true)
        multi_barcode_reader = GenericMultipleBarcodeReader.new(reader)

        multi_barcode_reader.decode_multiple(bitmap, hints).map do |result|
          barcode_format = barcode_format_to_sym(result.get_barcode_format)
          Result.new(barcode_format, result.get_text)
        end
      end

      private

      def barcode_format_to_sym(barcode_format)
        if barcode_format == BarcodeFormat::AZTEC
          :aztec
        elsif barcode_format == BarcodeFormat::CODABAR
          :codabar
        elsif barcode_format == BarcodeFormat::CODE_39
          :code_39
        elsif barcode_format == BarcodeFormat::CODE_93
          :code_93
        elsif barcode_format == BarcodeFormat::CODE_128
          :code_128
        elsif barcode_format == BarcodeFormat::DATA_MATRIX
          :data_matrix
        elsif barcode_format == BarcodeFormat::EAN_8
          :ean_8
        elsif barcode_format == BarcodeFormat::EAN_13
          :ean_13
        elsif barcode_format == BarcodeFormat::ITF
          :itf
        elsif barcode_format == BarcodeFormat::MAXICODE
          :maxicode
        elsif barcode_format == BarcodeFormat::PDF_417
          :pdf_417
        elsif barcode_format == BarcodeFormat::QR_CODE
          :qr_code
        elsif barcode_format == BarcodeFormat::RSS_14
          :rss_14
        elsif barcode_format == BarcodeFormat::RSS_EXPANDED
          :rss_expanded
        elsif barcode_format == BarcodeFormat::UPC_A
          :upc_a
        elsif barcode_format == BarcodeFormat::UPC_E
          :upc_e
        elsif barcode_format == BarcodeFormat::UPC_EAN_EXTENSION
          :upc_ean
        else
          :unknown
        end
      end

      def bitmap
        BinaryBitmap.new(binarizer)
      end

      def image
        ImageIO.read(io)
      end

      def io
        if file =~ URI.regexp(['http', 'https'])
          URL.new(file)
        else
          raise ArgumentError, "File #{file} could not be found" unless File.exist?(file)
          Java::JavaIO::File.new(file)
        end
      end

      def luminance
        BufferedImageLuminanceSource.new(image)
      end

      def binarizer
        GlobalHistogramBinarizer.new(luminance)
      end

      def hybrid_binarizer
        HybridBinarizer.new(luminance)
      end

      def hybrid_bitmap
        BinaryBitmap.new(hybrid_binarizer)
      end

      def qr_decode(bitmap)
        qrcode_reader.decode(bitmap).to_s
      rescue NotFoundException, FormatException
        nil
      rescue ArgumentError => e
        raise e
      rescue NativeException => e
        $stderr.puts "#{e.class}: #{e.message}"
        raise e
      end

      def qrcode_reader
        @qrcode_reader ||= QRCodeReader.new
      end
    end
  end
end

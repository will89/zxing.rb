require 'spec_helper'
require 'zxing'

class Foo
  def path
    File.expand_path("../fixtures/example.png", __FILE__)
  end
end

describe ZXing do
  describe ".decode" do
    let(:decode_result) { ZXing.decode(file) }

    context "with a string path to image" do
      let(:file) { fixture_image("example") }
      let(:expected_result) { ZXing::Result.new(:qr_code, 'example')}

      specify do
        expect(decode_result).to eq(expected_result)
      end
    end

    context "with a uri" do
      let(:file) { "http://2d-code.co.uk/images/bbc-logo-in-qr-code.gif" }
      let(:expected_result) { ZXing::Result.new(:qr_code, 'http://bbc.co.uk/programmes')}

      # TODO: How important is it to support scanning a http url?
      xspecify do
        expect(decode_result).to eq(expected_result)
      end
    end

    context "with an instance of File" do
      let(:file) { File.new(fixture_image("example")) }
      let(:expected_result) { ZXing::Result.new(:qr_code, 'example')}

      specify do
        expect(decode_result).to eq(expected_result)
      end
    end

    context "with an object that responds to #path" do
      let(:file) { Foo.new }
      let(:expected_result) { ZXing::Result.new(:qr_code, 'example')}

      specify do
        expect(decode_result).to eq(expected_result)
      end
    end

    context "when the image cannot be decoded" do
      let(:file) { fixture_image("cat") }
      let(:expected_result) { ZXing::Result.new(nil, nil)}

      specify do
        expect(decode_result).to be_nil
      end
    end

    context "when file does not exist" do
      let(:file) { 'nonexistentfile.png' }

      it "raises an error" do
        expect { decode_result }.to raise_error(ArgumentError, "File nonexistentfile.png could not be found")
      end
    end

  end

  describe ".decode!" do
    let(:decode_result) { ZXing.decode!(file) }

    context "with a qrcode file" do
      let(:file) { fixture_image("example") }
      let(:expected_result) { ZXing::Result.new(:qr_code, 'example')}

      specify do
        expect(decode_result).to eq(expected_result)
      end
    end

    context "when the image cannot be decoded" do
      let(:file) { fixture_image("cat") }

      it "raises an error" do
        expect { decode_result }.to raise_error(ZXing::UndecodableError, "Image not decodable")
      end
    end

    context "when the image cannot be decoded from a URL" do
      let(:file) { "http://www.google.com/logos/grandparentsday10.gif" }

      it "raises an error" do
        expect { decode_result }.to raise_error(ZXing::UndecodableError, "Image not decodable")
      end
    end

    context "when file does not exist" do
      let(:file) { 'nonexistentfile.png' }

      it "raises an error" do
        expect { decode_result }.to raise_error(ArgumentError, "File nonexistentfile.png could not be found")
      end
    end
  end

  describe ".decode_all" do
    let(:decode_result) { ZXing.decode_all(file) }

    context "with a single barcoded image" do
      let(:file) { fixture_image("example") }
      let(:expected_result) { [ZXing::Result.new(:qr_code, 'example')] }

      specify do
        expect(decode_result).to eq(expected_result)
      end
    end

    context "with a multiple barcoded image" do
      let(:file) {fixture_image("multi_barcode_example") }
      let(:expected_result) do
        [
            ZXing::Result.new(:qr_code, 'test456'),
            ZXing::Result.new(:qr_code, 'test123')
        ]
      end

      specify do
        expect(decode_result).to match_array(expected_result)
      end
    end

    context "when the image cannot be decoded" do
      let(:file) { fixture_image("cat") }

      specify do
        expect(decode_result).to eq([])
      end
    end

    context "when file does not exist" do
      let(:file) { 'nonexistentfile.png' }

      it "raises an error" do
        expect { decode_result }.to raise_error(ArgumentError, "File nonexistentfile.png could not be found")
      end
    end

  end

  describe ".decode_all!" do
    let(:decode_result) { ZXing.decode_all!(file) }

    context "with a single barcoded image" do
      let(:file) { fixture_image("example") }
      let(:expected_result) { [ZXing::Result.new(:qr_code, 'example')] }

      specify do
        expect(decode_result).to eq(expected_result)
      end
    end

    context "with a multiple barcoded image" do
      let(:file) {fixture_image("multi_barcode_example") }
      let(:expected_result) do
        [
            ZXing::Result.new(:qr_code, 'test456'),
            ZXing::Result.new(:qr_code, 'test123')
        ]
      end

      specify do
        expect(decode_result).to match_array(expected_result)
      end
    end

    context "when the image cannot be decoded" do
      let(:file) { fixture_image("cat") }

      it "raises an error" do
        expect { decode_result }.to raise_error(ZXing::UndecodableError, "Image not decodable")
      end
    end

    context "when file does not exist" do
      let(:file) { 'nonexistentfile.png' }

      it "raises an error" do
        expect { decode_result }.to raise_error(ArgumentError, "File nonexistentfile.png could not be found")
      end
    end
  end

  describe ".qrcode_decode" do
    let(:decode_result) { ZXing.qrcode_decode(file) }

    context "with image1" do
      let(:file) { File.new(fixture_image("img-0001")) }

      specify do
        expect(decode_result).to eq("SDQI:{\"name\":\"Miss Punniya  teston120416\",\"ess_id\":\"punniya prabhu\",\"tag\":\"General\"}")
      end
    end

    context "with image2" do
      let(:file) { File.new(fixture_image("img-0002")) }

      specify do
        expect(decode_result).to eq("SDQI:{\"job seeker name\":\"Tom Gouke\",\"id\":20012,\"tag\":\"abcdefgababcdefgababcdefgababcdefgab1234abcdefgababcdefgababcdefgababcdefgab1234abcdefgababcdefgababcdefgababcdefgab1234abcdefgababcdefgababcdefgababcdefgab1234\"}")
      end
    end

    context "with image3" do
      let(:file) { File.new(fixture_image("img-0003")) }

      specify do
        expect(decode_result).to eq("SDQI:{\"name\":\"Miss Punniya  teston120416\",\"ess_id\":\"punniya prabhu\",\"tag\":\"General\"}")
      end
    end

    context "with image4" do
      let(:file) { File.new(fixture_image("img-0004")) }

      specify do
        expect(decode_result).to eq("SDQI:{\"name\":\"Miss test name long long\",\"ess_id\":101016,\"tag\":\"test tags is very long very long very long very long\"}")
      end
    end

    context "with image5" do
      let(:file) { File.new(fixture_image("img-0005")) }

      specify do
        expect(decode_result).to eq("SDQI:{\"name\":\"Able Seaman pei han\",\"ess_id\":\"111\",\"tag\":\"resume1\"}")
      end
    end
  end
end

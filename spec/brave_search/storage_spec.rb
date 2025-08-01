# frozen_string_literal: true

require "spec_helper"

RSpec.describe BraveSearch::Storage do
  describe ".for" do
    it "returns S3 adapter for aws" do
      adapter = described_class.for(:aws, bucket: "test")
      expect(adapter).to be_a(BraveSearch::Storage::S3)
    end

    it "returns S3 adapter for hetzner" do
      adapter = described_class.for(:hetzner, bucket: "test", endpoint: "https://fsn1.your-objectstorage.com")
      expect(adapter).to be_a(BraveSearch::Storage::S3)
    end

    it "raises error for unknown storage" do
      expect { described_class.for(:unknown) }.to raise_error(ArgumentError)
    end
  end
end

RSpec.describe BraveSearch::Storage::S3 do
  let(:adapter) { described_class.new(bucket: "test-bucket") }

  describe "#upload" do
    it "uploads file to S3" do
      file_content = "test content"
      key = "test/file.pdf"

      expect(adapter.upload(file_content, key: key)).to include(url: /test-bucket/)
    end
  end

  describe "#download" do
    it "downloads file from URL to S3" do
      url = "https://example.com/file.pdf"
      key = "downloads/file.pdf"

      stub_request(:get, url).to_return(body: "pdf content")

      result = adapter.download(url, key: key)
      expect(result).to include(key: key, size: 11)
    end
  end
end

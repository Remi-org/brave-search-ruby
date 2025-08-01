# frozen_string_literal: true

require "spec_helper"

RSpec.describe BraveSearch::PdfDownloader do
  let(:storage) { instance_double(BraveSearch::Storage::S3) }
  let(:downloader) { described_class.new(storage: storage) }

  describe "#download" do
    it "downloads single PDF to storage" do
      url = "https://example.com/paper.pdf"

      allow(storage).to receive(:download).with(url, key: "pdfs/paper.pdf")
                                          .and_return(key: "pdfs/paper.pdf", size: 1024)

      result = downloader.download(url)

      expect(result[:key]).to eq("pdfs/paper.pdf")
      expect(result[:size]).to eq(1024)
    end
  end

  describe "#batch_download" do
    it "downloads multiple PDFs concurrently" do
      urls = [
        "https://example.com/paper1.pdf",
        "https://example.com/paper2.pdf"
      ]

      allow(storage).to receive(:download).and_return(size: 1024)

      results = downloader.batch_download(urls)

      expect(results).to be_an(Array)
      expect(results.length).to eq(2)
    end

    it "calls progress callback" do
      urls = ["https://example.com/paper.pdf"]
      progress_calls = []

      allow(storage).to receive(:download).and_return(size: 1024)

      downloader.batch_download(urls) do |completed, total|
        progress_calls << { completed: completed, total: total }
      end

      expect(progress_calls).to include(completed: 1, total: 1)
    end
  end
end

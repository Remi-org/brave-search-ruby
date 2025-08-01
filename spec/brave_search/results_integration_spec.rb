# frozen_string_literal: true

require "spec_helper"

RSpec.describe BraveSearch::Results, "PDF integration" do
  let(:sample_data) do
    {
      web: {
        results: [
          { title: "Ruby Guide", url: "https://example.com/guide.pdf", description: "PDF guide" },
          { title: "Ruby Tutorial", url: "https://example.com/tutorial.html", description: "HTML tutorial" },
          { title: "Research Paper", url: "https://example.com/paper.pdf", description: "PDF paper" }
        ]
      }
    }
  end

  let(:results) { described_class.new(sample_data) }

  describe "#pdf_urls" do
    it "extracts PDF URLs from web results" do
      pdf_urls = results.pdf_urls

      expect(pdf_urls).to eq([
                               "https://example.com/guide.pdf",
                               "https://example.com/paper.pdf"
                             ])
    end

    it "returns empty array when no PDFs found" do
      data = { web: { results: [{ title: "Test", url: "https://example.com/page.html" }] } }
      results = described_class.new(data)

      expect(results.pdf_urls).to eq([])
    end
  end

  describe "#download_pdfs" do
    it "downloads PDFs using provided storage" do
      storage = instance_double(BraveSearch::Storage::S3)
      downloader = instance_double(BraveSearch::PdfDownloader)

      allow(BraveSearch::PdfDownloader).to receive(:new).with(storage: storage).and_return(downloader)
      allow(downloader).to receive(:batch_download).with(results.pdf_urls, folder: "test").and_return([])

      results.download_pdfs(storage: storage, folder: "test")

      expect(downloader).to have_received(:batch_download)
    end
  end
end

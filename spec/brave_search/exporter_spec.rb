# frozen_string_literal: true

require "spec_helper"

RSpec.describe BraveSearch::Exporter do
  let(:sample_results) do
    BraveSearch::Results.new({
                               web: {
                                 results: [
                                   { title: "Ruby Guide", url: "https://example.com", description: "Learn Ruby" },
                                   { title: "Rails Tutorial", url: "https://tutorial.com", description: "Build apps" }
                                 ]
                               }
                             })
  end

  describe ".for" do
    it "returns JSON exporter" do
      exporter = described_class.for(:json)
      expect(exporter).to be_a(BraveSearch::Exporters::Json)
    end

    it "returns CSV exporter" do
      exporter = described_class.for(:csv)
      expect(exporter).to be_a(BraveSearch::Exporters::Csv)
    end

    it "returns XLSX exporter" do
      exporter = described_class.for(:xlsx)
      expect(exporter).to be_a(BraveSearch::Exporters::Xlsx)
    end

    it "raises error for unknown format" do
      expect { described_class.for(:unknown) }.to raise_error(ArgumentError)
    end
  end

  describe "#export" do
    it "exports results to format" do
      exporter = BraveSearch::Exporter.for(:json)
      result = exporter.export(sample_results)

      expect(result).to include(content: String, size: Integer)
      expect(result[:content]).to include("Ruby Guide")
    end
  end

  describe "#export_to_storage" do
    it "exports and uploads to storage" do
      storage = instance_double(BraveSearch::Storage::S3)
      exporter = BraveSearch::Exporter.for(:json)

      allow(storage).to receive(:upload).and_return(url: "https://s3.example.com/test.json", size: 100)

      result = exporter.export_to_storage(sample_results, storage: storage, key: "test.json")

      expect(result).to include(url: "https://s3.example.com/test.json")
      expect(result[:size]).to be > 0
      expect(storage).to have_received(:upload)
    end
  end
end

describe "JSON Exporter" do
  let(:results) do
    BraveSearch::Results.new({
                               web: { results: [{ title: "Test", url: "https://example.com" }] }
                             })
  end

  it "exports results as JSON" do
    exporter = BraveSearch::Exporter.for(:json)
    result = exporter.export(results)

    parsed = JSON.parse(result[:content])
    expect(parsed["web"]["results"]).to be_an(Array)
    expect(parsed["web"]["results"].first["title"]).to eq("Test")
  end
end

describe "CSV Exporter" do
  let(:results) do
    BraveSearch::Results.new({
                               web: { results: [
                                 { title: "Test 1", url: "https://example.com", description: "First" },
                                 { title: "Test 2", url: "https://example2.com", description: "Second" }
                               ] }
                             })
  end

  it "exports web results as CSV" do
    exporter = BraveSearch::Exporter.for(:csv)
    result = exporter.export(results)

    lines = result[:content].split("\n")
    expect(lines.first).to eq("title,url,description")
    expect(lines[1]).to include("Test 1,https://example.com,First")
    expect(lines[2]).to include("Test 2,https://example2.com,Second")
  end
end

describe "XLSX Exporter" do
  let(:results) do
    BraveSearch::Results.new({
                               web: { results: [
                                 { title: "Excel Test", url: "https://example.com", description: "Spreadsheet data" }
                               ] }
                             })
  end

  it "exports web results as XLSX" do
    exporter = BraveSearch::Exporter.for(:xlsx)
    result = exporter.export(results)

    expect(result[:content]).to be_a(String)
    expect(result[:size]).to be > 0
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Export Integration" do
  let(:client) { BraveSearch::Client.new(api_key: "test_key") }
  let(:storage) { instance_double(BraveSearch::Storage::S3) }

  let(:mock_response) do
    {
      web: {
        results: [
          { title: "Ruby Guide", url: "https://example.com/guide.pdf", description: "Complete Ruby guide" },
          { title: "Rails Tutorial", url: "https://tutorial.com", description: "Build web apps" }
        ]
      }
    }
  end

  before do
    stub_request(:get, "https://api.search.brave.com/res/v1/web/search")
      .with(query: hash_including(q: "ruby programming"))
      .to_return(
        status: 200,
        body: mock_response.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  describe "search and export workflow" do
    it "exports search results to JSON" do
      result = client.search_and_export(q: "ruby programming", format: :json)

      expect(result[:content]).to include("Ruby Guide")
      expect(result[:size]).to be > 0
    end

    it "exports search results to CSV" do
      result = client.search_and_export(q: "ruby programming", format: :csv)

      expect(result[:content]).to include("title,url,description")
      expect(result[:content]).to include("Ruby Guide")
    end

    it "exports search results to XLSX" do
      result = client.search_and_export(q: "ruby programming", format: :xlsx)

      expect(result[:content]).to be_a(String)
      expect(result[:size]).to be > 0
    end
  end

  describe "search and export to storage workflow" do
    before do
      allow(storage).to receive(:upload).and_return(
        url: "https://s3.example.com/exports/results.json",
        size: 250
      )
    end

    it "exports and uploads search results to storage" do
      result = client.search_and_export(
        q: "ruby programming",
        format: :json,
        storage: storage,
        key: "exports/ruby-results.json"
      )

      expect(result[:url]).to eq("https://s3.example.com/exports/results.json")
      expect(result[:key]).to eq("exports/ruby-results.json")
      expect(result[:format]).to eq("json")
      expect(storage).to have_received(:upload).with(
        String, key: "exports/ruby-results.json"
      )
    end
  end

  describe "results export methods" do
    let(:results) { client.search(q: "ruby programming") }

    it "exports results using results method" do
      result = results.export(format: :json)

      expect(result[:content]).to include("Ruby Guide")
    end

    it "exports to storage using results method" do
      allow(storage).to receive(:upload).and_return(
        url: "https://s3.example.com/results.csv",
        size: 150
      )

      result = results.export_to_storage(
        format: :csv,
        storage: storage,
        key: "results.csv"
      )

      expect(result[:url]).to eq("https://s3.example.com/results.csv")
      expect(storage).to have_received(:upload)
    end
  end
end

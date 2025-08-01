# frozen_string_literal: true

require "spec_helper"

RSpec.describe BraveSearch::AsyncClient do
  let(:api_key) { "test_api_key" }
  let(:client) { described_class.new(api_key: api_key) }

  describe "#search" do
    let(:search_response) do
      {
        web: {
          results: [
            {
              title: "Ruby Programming",
              url: "https://example.com",
              description: "Learn Ruby programming"
            }
          ]
        }
      }
    end

    before do
      stub_request(:get, "https://api.search.brave.com/res/v1/web/search")
        .with(
          query: { q: "ruby programming", count: 10 },
          headers: {
            "X-Subscription-Token" => api_key,
            "Accept" => "application/json"
          }
        )
        .to_return(
          status: 200,
          body: search_response.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "returns async search results" do
      Async do
        result = client.search(q: "ruby programming").wait

        expect(result).to be_a(BraveSearch::Results)
        expect(result.web_results).to be_an(Array)
        expect(result.web_results.first[:title]).to eq("Ruby Programming")
      end
    end
  end

  describe "#concurrent_search" do
    before do
      stub_request(:get, "https://api.search.brave.com/res/v1/web/search")
        .with(query: hash_including(q: "ruby"))
        .to_return(
          status: 200,
          body: { web: { results: [{ title: "Ruby Result" }] } }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      stub_request(:get, "https://api.search.brave.com/res/v1/web/search")
        .with(query: hash_including(q: "rails"))
        .to_return(
          status: 200,
          body: { web: { results: [{ title: "Rails Result" }] } }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "performs concurrent searches" do
      Async do
        results = client.concurrent_search(%w[ruby rails]).wait

        expect(results).to be_an(Array)
        expect(results.length).to eq(2)
        expect(results.all? { |r| r.is_a?(BraveSearch::Results) }).to be true
      end
    end
  end
end

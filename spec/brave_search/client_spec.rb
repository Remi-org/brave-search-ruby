# frozen_string_literal: true

require "spec_helper"

RSpec.describe BraveSearch::Client do
  let(:api_key) { "test_api_key" }
  let(:client) { described_class.new(api_key: api_key) }

  describe "#initialize" do
    it "raises error without API key" do
      expect { described_class.new }.to raise_error(BraveSearch::AuthenticationError)
    end

    it "accepts API key parameter" do
      expect { described_class.new(api_key: api_key) }.not_to raise_error
    end
  end

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

    it "returns search results" do
      result = client.search(q: "ruby programming")

      expect(result).to be_a(BraveSearch::Results)
      expect(result.web_results).to be_an(Array)
      expect(result.web_results.first[:title]).to eq("Ruby Programming")
    end

    it "handles authentication errors" do
      stub_request(:get, "https://api.search.brave.com/res/v1/web/search")
        .with(
          query: { q: "test", count: 10 },
          headers: {
            "X-Subscription-Token" => api_key,
            "Accept" => "application/json"
          }
        )
        .to_return(status: 401)

      expect { client.search(q: "test") }.to raise_error(BraveSearch::AuthenticationError)
    end

    it "handles rate limit errors" do
      stub_request(:get, "https://api.search.brave.com/res/v1/web/search")
        .with(
          query: { q: "test", count: 10 },
          headers: {
            "X-Subscription-Token" => api_key,
            "Accept" => "application/json"
          }
        )
        .to_return(status: 429)

      expect { client.search(q: "test") }.to raise_error(BraveSearch::RateLimitError)
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe BraveSearch::Results do
  let(:sample_data) do
    {
      query: { original: "ruby programming" },
      web: {
        results: [
          { title: "Ruby Programming", url: "https://example.com", description: "Learn Ruby" },
          { title: "Ruby Tutorial", url: "https://tutorial.com", description: "Ruby basics" }
        ]
      },
      news: {
        results: [
          { title: "Ruby News", url: "https://news.com", description: "Latest Ruby news" }
        ]
      }
    }
  end

  let(:results) { described_class.new(sample_data) }

  describe "#web_results" do
    it "returns web results array" do
      expect(results.web_results).to be_an(Array)
      expect(results.web_results.length).to eq(2)
      expect(results.web_results.first[:title]).to eq("Ruby Programming")
    end
  end

  describe "#news_results" do
    it "returns news results array" do
      expect(results.news_results).to be_an(Array)
      expect(results.news_results.length).to eq(1)
      expect(results.news_results.first[:title]).to eq("Ruby News")
    end
  end

  describe "#empty?" do
    it "returns false when results exist" do
      expect(results.empty?).to be false
    end

    it "returns true when no results exist" do
      empty_results = described_class.new({})
      expect(empty_results.empty?).to be true
    end
  end

  describe "#count" do
    it "returns total count of all results" do
      expect(results.count).to eq(3) # 2 web + 1 news
    end
  end

  describe "pattern matching support" do
    it "supports deconstruct_keys for pattern matching" do
      case results
      in { web: { results: Array => web_items } }
        expect(web_items.length).to eq(2)
      else
        raise "Pattern matching failed"
      end
    end
  end

  describe "#[]" do
    it "allows hash-like access" do
      expect(results[:web][:results].length).to eq(2)
      expect(results[:query][:original]).to eq("ruby programming")
    end
  end
end

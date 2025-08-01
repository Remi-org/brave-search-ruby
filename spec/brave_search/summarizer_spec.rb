# frozen_string_literal: true

require "spec_helper"

RSpec.describe BraveSearch::Summarizer do
  let(:client) { BraveSearch::Client.new(api_key: "test_key") }
  let(:summarizer) { client.summarizer }

  describe "#search_and_summarize" do
    let(:mock_response) do
      {
        type: "summarizer",
        summarizer: {
          key: "test-key-123",
          type: "search",
          status: "success",
          summary: ["Key finding about AI research", "Another important insight"],
          enriched_results: [
            {
              title: "AI Research Paper",
              url: "https://example.com/paper",
              description: "Latest findings in AI",
              snippets: ["Context snippet 1", "Context snippet 2"]
            }
          ]
        }
      }
    end

    before do
      stub_request(:post, "https://api.search.brave.com/res/v1/summarizer/search")
        .with(body: hash_including(q: "AI research"))
        .to_return(
          status: 200,
          body: mock_response.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "searches and returns summary with enriched results" do
      result = summarizer.search_and_summarize(q: "AI research")

      expect(result.summary).to eq(["Key finding about AI research", "Another important insight"])
      expect(result.enriched_results).to be_an(Array)
      expect(result.enriched_results.first.title).to eq("AI Research Paper")
    end

    it "returns structured summary object" do
      result = summarizer.search_and_summarize(q: "AI research")

      expect(result).to respond_to(:summary)
      expect(result).to respond_to(:enriched_results)
      expect(result).to respond_to(:key)
      expect(result).to respond_to(:status)
    end
  end

  describe "#summarize" do
    let(:mock_summary_response) do
      {
        type: "summarizer",
        summarizer: {
          key: "summary-key-456",
          type: "summary",
          status: "success",
          summary: ["Synthesized summary of provided content"]
        }
      }
    end

    before do
      stub_request(:post, "https://api.search.brave.com/res/v1/summarizer/summary")
        .with(body: hash_including(key: "test-key-123"))
        .to_return(
          status: 200,
          body: mock_summary_response.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "summarizes existing search results" do
      result = summarizer.summarize(key: "test-key-123")

      expect(result.summary).to eq(["Synthesized summary of provided content"])
      expect(result.status).to eq("success")
    end
  end

  describe "fluent interface" do
    it "supports method chaining" do
      allow(summarizer).to receive(:search_and_summarize).and_return(
        double(summary: ["Test"], key: "key-123")
      )
      allow(summarizer).to receive(:summarize).and_return(
        double(summary: ["Final summary"])
      )

      result = client.summarizer
                     .search_and_summarize(q: "test")
                     .then { |initial| summarizer.summarize(key: initial.key) }

      expect(result.summary).to eq(["Final summary"])
    end
  end
end

RSpec.describe BraveSearch::SummaryResult do
  subject { BraveSearch::SummaryResult.new(data) }

  let(:data) do
    {
      summarizer: {
        key: "test-key",
        type: "search",
        status: "success",
        summary: ["Key point 1", "Key point 2"],
        enriched_results: [
          { title: "Test", url: "https://example.com", description: "Test desc" }
        ]
      }
    }
  end

  it "provides access to summary data" do
    expect(subject.summary).to eq(["Key point 1", "Key point 2"])
    expect(subject.key).to eq("test-key")
    expect(subject.status).to eq("success")
  end

  it "provides structured access to enriched results" do
    expect(subject.enriched_results).to be_an(Array)
    expect(subject.enriched_results.first).to respond_to(:title)
    expect(subject.enriched_results.first).to respond_to(:url)
  end

  it "supports pattern matching" do
    case subject
    in { summary: Array => points, status: "success" }
      expect(points.length).to eq(2)
    else
      raise "Pattern matching failed"
    end
  end
end

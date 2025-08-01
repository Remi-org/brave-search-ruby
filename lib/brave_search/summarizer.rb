# frozen_string_literal: true

module BraveSearch
  class Summarizer
    SEARCH_ENDPOINT = "/summarizer/search"
    SUMMARY_ENDPOINT = "/summarizer/summary"

    def initialize(client)
      @client = client
    end

    def search_and_summarize(q:, **options)
      params = build_search_params(q: q, **options)
      make_summarizer_request(SEARCH_ENDPOINT, params)
    end

    def summarize(key:, **options)
      params = build_summary_params(key: key, **options)
      make_summarizer_request(SUMMARY_ENDPOINT, params)
    end

    private

    def make_summarizer_request(endpoint, params)
      response = @client.send(:make_request, endpoint, params, method: :post)
      data = @client.send(:handle_response, response)
      SummaryResult.new(data)
    end

    def build_search_params(q:, **options)
      { q: q }.merge(options.compact)
    end

    def build_summary_params(key:, **options)
      { key: key }.merge(options.compact)
    end
  end
end

# frozen_string_literal: true

module BraveSearch
  class SummaryResult
    attr_reader :raw_data

    def initialize(data)
      @raw_data = data
    end

    def summary
      @raw_data.dig(:summarizer, :summary) || []
    end

    def key
      @raw_data.dig(:summarizer, :key)
    end

    def status
      @raw_data.dig(:summarizer, :status)
    end

    def type
      @raw_data.dig(:summarizer, :type)
    end

    def enriched_results
      results = @raw_data.dig(:summarizer, :enriched_results) || []
      results.map { |result| EnrichedResult.new(result) }
    end

    # Support pattern matching (Ruby 3+)
    def deconstruct_keys(keys)
      hash = {
        summary: summary,
        key: key,
        status: status,
        type: type,
        enriched_results: enriched_results
      }
      keys ? hash.slice(*keys) : hash
    end

    def to_h
      @raw_data
    end
  end

  class EnrichedResult
    attr_reader :raw_data

    def initialize(data)
      @raw_data = data
    end

    def title
      @raw_data[:title]
    end

    def url
      @raw_data[:url]
    end

    def description
      @raw_data[:description]
    end

    def snippets
      @raw_data[:snippets] || []
    end

    def to_h
      @raw_data
    end
  end
end

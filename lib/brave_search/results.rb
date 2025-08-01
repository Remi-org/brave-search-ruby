# frozen_string_literal: true

module BraveSearch
  class Results
    attr_reader :raw_data, :query

    def initialize(data)
      @raw_data = data
      @query = data[:query]
    end

    def web_results
      @raw_data.dig(:web, :results) || []
    end

    def news_results
      @raw_data.dig(:news, :results) || []
    end

    def video_results
      @raw_data.dig(:videos, :results) || []
    end

    def image_results
      @raw_data.dig(:images, :results) || []
    end

    def locations
      @raw_data.dig(:mixed, :locations) || []
    end

    def infobox
      @raw_data.dig(:mixed, :infobox)
    end

    def spell
      @raw_data[:spell]
    end

    def empty?
      web_results.empty? && news_results.empty? && video_results.empty? && image_results.empty?
    end

    def count
      web_results.length + news_results.length + video_results.length + image_results.length
    end

    # Support pattern matching (Ruby 3+)
    def deconstruct_keys(keys)
      @raw_data.slice(*keys) if keys
      @raw_data
    end

    # Convert to hash for easy access
    def to_h
      @raw_data
    end

    def [](key)
      @raw_data[key]
    end
  end
end

# frozen_string_literal: true

module BraveSearch
  module Exporters
    class Base < BraveSearch::Exporter
      private

      def validate_results(results)
        raise ArgumentError, "Results cannot be nil" if results.nil?
        raise ArgumentError, "Results must respond to web_results" unless results.respond_to?(:web_results)
      end

      def build_metadata(results)
        {
          exported_at: Time.now.iso8601,
          query: results.query,
          total_results: results.count,
          format: format_name
        }
      end
    end
  end
end

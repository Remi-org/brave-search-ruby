# frozen_string_literal: true

require "csv"
require_relative "base"

module BraveSearch
  module Exporters
    class Csv < Base
      def export(results)
        validate_results(results)
        content = generate_csv(results)

        {
          content: content,
          size: content.bytesize
        }
      end

      private

      def generate_csv(results)
        CSV.generate do |csv|
          csv << %w[title url description]

          results.web_results.each do |result|
            csv << [result[:title], result[:url], result[:description]]
          end
        end
      end
    end
  end
end

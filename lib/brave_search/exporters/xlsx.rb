# frozen_string_literal: true

require "caxlsx"
require_relative "base"

module BraveSearch
  module Exporters
    class Xlsx < Base
      def export(results)
        validate_results(results)
        content = generate_xlsx(results)

        {
          content: content,
          size: content.bytesize
        }
      end

      private

      def generate_xlsx(results)
        package = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: "Search Results") do |sheet|
          sheet.add_row %w[Title URL Description]

          results.web_results.each do |result|
            sheet.add_row [result[:title], result[:url], result[:description]]
          end
        end

        add_metadata_sheet(workbook, results)
        package.to_stream.read
      end

      def add_metadata_sheet(workbook, results)
        workbook.add_worksheet(name: "Metadata") do |sheet|
          metadata = build_metadata(results)

          sheet.add_row %w[Property Value]
          metadata.each { |key, value| sheet.add_row [key.to_s.tr("_", " ").capitalize, value] }
        end
      end
    end
  end
end

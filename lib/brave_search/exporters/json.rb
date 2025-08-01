# frozen_string_literal: true

require "json"
require_relative "base"

module BraveSearch
  module Exporters
    class Json < Base
      def export(results)
        validate_results(results)

        export_data = results.to_h.merge(
          metadata: build_metadata(results)
        )

        content = JSON.pretty_generate(export_data)

        {
          content: content,
          size: content.bytesize
        }
      end
    end
  end
end

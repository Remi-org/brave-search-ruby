# frozen_string_literal: true

module BraveSearch
  class Exporter
    def self.for(format)
      case format
      when :json
        require_relative "exporters/json"
        Exporters::Json.new
      when :csv
        require_relative "exporters/csv"
        Exporters::Csv.new
      when :xlsx
        require_relative "exporters/xlsx"
        Exporters::Xlsx.new
      else
        raise ArgumentError, "Unknown export format: #{format}"
      end
    end

    def export(results)
      raise NotImplementedError, "Subclasses must implement #export"
    end

    def export_to_storage(results, storage:, key:)
      export_result = export(results)
      upload_result = storage.upload(export_result[:content], key: key)

      {
        key: key,
        url: upload_result[:url],
        size: export_result[:size],
        format: format_name
      }
    end

    private

    def format_name
      self.class.name.split("::").last.downcase
    end
  end
end

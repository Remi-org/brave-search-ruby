# frozen_string_literal: true

module BraveSearch
  module Jobs
    class ExportJob < ActiveJob::Base
      queue_as :brave_search

      def perform(query:, format:, storage_config: nil, key: nil, **search_options)
        client = BraveSearch::Client.new

        if storage_config && key
          storage = build_storage(storage_config)
          result = client.search_and_export(
            q: query,
            format: format.to_sym,
            storage: storage,
            key: key,
            **search_options
          )

          Rails.logger.info "Export completed: #{result[:url]}"
        else
          result = client.search_and_export(q: query, format: format.to_sym, **search_options)
          Rails.logger.info "Export completed locally: #{result[:size]} bytes"
        end

        result
      end

      private

      def build_storage(config)
        BraveSearch::Storage.for(
          config[:provider],
          **config[:options]
        )
      end
    end
  end
end

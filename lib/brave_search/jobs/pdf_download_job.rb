# frozen_string_literal: true

module BraveSearch
  module Jobs
    class PdfDownloadJob < ActiveJob::Base
      queue_as :brave_search

      def perform(query:, storage_config: nil, folder: "pdfs", **search_options)
        client = BraveSearch::Client.new
        storage = storage_config ? build_storage(storage_config) : nil

        progress_callback = lambda do |current, total, url|
          Rails.logger.info "Downloading PDFs: #{current}/#{total} - #{url}"
        end

        result = client.search_and_download_pdfs(
          q: query,
          storage: storage,
          folder: folder,
          **search_options,
          &progress_callback
        )

        Rails.logger.info "PDF download completed: #{result[:files].size} files"
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

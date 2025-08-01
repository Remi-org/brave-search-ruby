# frozen_string_literal: true

require "concurrent-ruby"

module BraveSearch
  class PdfDownloader
    def initialize(storage: nil)
      @storage = storage || default_storage
    end

    def download(url, folder: "pdfs")
      filename = extract_filename(url)
      key = "#{folder}/#{filename}"
      
      @storage.download(url, key: key)
    end

    def batch_download(urls, folder: "pdfs", &progress_callback)
      total = urls.length
      completed = Concurrent::AtomicFixnum.new(0)
      
      futures = urls.map do |url|
        Concurrent::Future.execute do
          result = download(url, folder: folder)
          current = completed.increment
          progress_callback&.call(current, total)
          result
        end
      end

      futures.map(&:value)
    end

    private

    def default_storage
      Storage.for(:aws, bucket: ENV.fetch("BRAVE_SEARCH_BUCKET", "brave-search-downloads"))
    end

    def extract_filename(url)
      uri = URI(url)
      filename = File.basename(uri.path)
      filename.empty? ? "document.pdf" : filename
    end
  end
end
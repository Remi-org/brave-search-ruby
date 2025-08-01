# frozen_string_literal: true

module BraveSearch
  class Configuration
    attr_accessor :api_key, :base_url, :timeout, :retry_attempts, :storage_provider, :storage_bucket, :storage_endpoint

    def initialize
      @api_key = ENV.fetch("BRAVE_API_KEY", nil)
      @base_url = "https://api.search.brave.com/res/v1"
      @timeout = 30
      @retry_attempts = 3
      @storage_provider = :aws
      @storage_bucket = ENV.fetch("BRAVE_SEARCH_BUCKET", "brave-search-downloads")
      @storage_endpoint = nil
    end

    def storage(**options)
      Storage.for(storage_provider, bucket: storage_bucket, endpoint: storage_endpoint, **options)
    end
  end
end

# frozen_string_literal: true

module BraveSearch
  class Configuration
    attr_accessor :api_key, :base_url, :timeout, :retry_attempts

    def initialize
      @api_key = ENV.fetch("BRAVE_API_KEY", nil)
      @base_url = "https://api.search.brave.com/res/v1"
      @timeout = 30
      @retry_attempts = 3
    end
  end
end

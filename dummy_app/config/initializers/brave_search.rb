# frozen_string_literal: true

BraveSearch.configure do |config|
  # Get your API key from https://brave.com/search/api/
  config.api_key = Rails.application.credentials.brave_api_key
  
  # Optional configuration
  # config.timeout = 30
  # config.retry_attempts = 3
end

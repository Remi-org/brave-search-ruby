# frozen_string_literal: true

require "rails/generators"

module BraveSearch
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def create_initializer
      create_file "config/initializers/brave_search.rb", <<~RUBY
        # frozen_string_literal: true

        BraveSearch.configure do |config|
          # Get your API key from https://brave.com/search/api/
          config.api_key = Rails.application.credentials.brave_api_key
        #{'  '}
          # Optional configuration
          # config.timeout = 30
          # config.retry_attempts = 3
        end
      RUBY
    end

    def show_instructions
      say <<~TEXT

        BraveSearch has been installed!

        Next steps:
        1. Get your API key from https://brave.com/search/api/
        2. Add it to your Rails credentials:
           rails credentials:edit
        #{'   '}
           Add this line:
           brave_api_key: your_api_key_here

        3. Use the client:
           client = BraveSearch::Client.new
           results = client.search(q: "ruby programming")

      TEXT
    end
  end
end

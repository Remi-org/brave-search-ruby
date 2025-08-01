# frozen_string_literal: true

module BraveSearch
  class Railtie < Rails::Railtie
    initializer "brave_search.configure" do |app|
      app.config.to_prepare do
        if Rails.application.credentials.brave_api_key
          BraveSearch.configure do |config|
            config.api_key = Rails.application.credentials.brave_api_key
          end
        end
      end
    end
  end
end

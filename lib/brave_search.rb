# frozen_string_literal: true

require_relative "brave_search/version"
require_relative "brave_search/configuration"
require_relative "brave_search/results"
require_relative "brave_search/client"
require_relative "brave_search/async_client"
require_relative "brave_search/railtie" if defined?(Rails)

module BraveSearch
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class RateLimitError < Error; end
  class QuotaExceededError < Error; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.config
    self.configuration ||= Configuration.new
  end
end

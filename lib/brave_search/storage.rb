# frozen_string_literal: true

require_relative "storage/s3"

module BraveSearch
  module Storage
    ADAPTERS = {
      aws: S3,
      hetzner: S3,
      digitalocean: S3,
      s3: S3
    }.freeze

    def self.for(provider, **options)
      adapter_class = ADAPTERS[provider]
      raise ArgumentError, "Unknown storage provider: #{provider}" unless adapter_class

      adapter_class.new(**options)
    end
  end
end
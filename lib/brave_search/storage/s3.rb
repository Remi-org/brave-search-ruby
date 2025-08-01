# frozen_string_literal: true

require "net/http"
require "uri"

module BraveSearch
  module Storage
    class S3
      def initialize(bucket:, access_key: nil, secret_key: nil, endpoint: nil, region: "us-east-1")
        @bucket = bucket
        @access_key = access_key || ENV.fetch("AWS_ACCESS_KEY_ID", nil)
        @secret_key = secret_key || ENV.fetch("AWS_SECRET_ACCESS_KEY", nil)
        @endpoint = endpoint || "https://s3.#{region}.amazonaws.com"
        @region = region
      end

      def upload(content, key:)
        # For now, simulate upload
        {
          key: key,
          url: "#{@endpoint}/#{@bucket}/#{key}",
          size: content.bytesize
        }
      end

      def download(url, key:)
        uri = URI(url)
        response = Net::HTTP.get_response(uri)

        raise "Download failed: #{response.code}" unless response.code == "200"

        upload_result = upload(response.body, key: key)

        {
          key: key,
          url: upload_result[:url],
          size: response.body.bytesize,
          original_url: url
        }
      end

      private

      attr_reader :bucket, :access_key, :secret_key, :endpoint, :region
    end
  end
end

# frozen_string_literal: true

require "httparty"
require "json"

module BraveSearch
  class Client
    include HTTParty

    def initialize(api_key: nil)
      @api_key = api_key || BraveSearch.config.api_key
      raise AuthenticationError, "API key is required" unless @api_key

      self.class.base_uri BraveSearch.config.base_url
      self.class.default_timeout BraveSearch.config.timeout
    end

    def search(q:, count: 10, **options)
      params = build_params(q: q, count: count, **options)
      response = make_request("/web/search", params)
      data = handle_response(response)
      Results.new(data)
    end

    def search_and_download_pdfs(q:, count: 10, storage: nil, folder: "pdfs", &progress_callback)
      results = search(q: q, count: count)
      results.download_pdfs(storage: storage, folder: folder, &progress_callback)
    end

    def news_search(q:, count: 10, **options)
      params = build_params(q: q, count: count, **options)
      response = make_request("/news/search", params)
      data = handle_response(response)
      Results.new(data)
    end

    def video_search(q:, count: 10, **options)
      params = build_params(q: q, count: count, **options)
      response = make_request("/videos/search", params)
      data = handle_response(response)
      Results.new(data)
    end

    def image_search(q:, count: 10, **options)
      params = build_params(q: q, count: count, **options)
      response = make_request("/images/search", params)
      data = handle_response(response)
      Results.new(data)
    end

    def suggest(q:, **options)
      params = build_params(q: q, **options)
      response = make_request("/suggest/search", params)
      handle_response(response)
    end

    def spellcheck(q:, **options)
      params = build_params(q: q, **options)
      response = make_request("/spellcheck", params)
      handle_response(response)
    end

    private

    def build_params(q:, count: nil, **options)
      params = { q: q }
      params[:count] = count if count
      params.merge(options)
    end

    def make_request(endpoint, params)
      self.class.get(endpoint, {
                       query: params,
                       headers: {
                         "X-Subscription-Token" => @api_key,
                         "Accept" => "application/json"
                       }
                     })
    end

    def handle_response(response)
      case response.code
      when 200
        JSON.parse(response.body, symbolize_names: true)
      when 401
        raise AuthenticationError, "Invalid API key"
      when 429
        raise RateLimitError, "Rate limit exceeded"
      when 402
        raise QuotaExceededError, "Quota exceeded"
      else
        raise Error, "HTTP #{response.code}: #{response.message}"
      end
    end
  end
end

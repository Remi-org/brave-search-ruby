# frozen_string_literal: true

require "async"

module BraveSearch
  class AsyncClient < Client
    def search(q:, count: 10, **options)
      Async do
        super(q: q, count: count, **options)
      end
    end

    def news_search(q:, count: 10, **options)
      Async do
        super(q: q, count: count, **options)
      end
    end

    def video_search(q:, count: 10, **options)
      Async do
        super(q: q, count: count, **options)
      end
    end

    def image_search(q:, count: 10, **options)
      Async do
        super(q: q, count: count, **options)
      end
    end

    def concurrent_search(queries)
      Async do
        tasks = queries.map do |query_params|
          Async do
            if query_params.is_a?(String)
              params = build_params(q: query_params)
              response = make_request("/web/search", params)
              data = handle_response(response)
              BraveSearch::Results.new(data)
            else
              params = build_params(**query_params)
              response = make_request("/web/search", params)
              data = handle_response(response)
              BraveSearch::Results.new(data)
            end
          end
        end
        tasks.map(&:wait)
      end
    end
  end
end

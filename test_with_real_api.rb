#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/brave_search"
require "json"

puts "BraveSearch Real API Test"
puts "=" * 40

# Check for API key
api_key = ENV.fetch("BRAVE_API_KEY", nil)
if api_key.nil? || api_key.empty?
  puts "❌ Please set BRAVE_API_KEY environment variable"
  puts "Usage: BRAVE_API_KEY=your_key ruby test_with_real_api.rb"
  exit 1
end

begin
  client = BraveSearch::Client.new(api_key: api_key)
  puts "✅ Client initialized with API key: #{api_key[0..8]}..."

  # Test basic search
  puts "\n🔍 Testing search: 'ruby programming'"
  results = client.search(q: "ruby programming", count: 3)

  puts "✅ Search successful!"
  puts "Query: #{results.dig(:query, :original) || 'ruby programming'}"

  if results[:web] && results[:web][:results]
    puts "📄 Found #{results[:web][:results].length} web results:"

    results[:web][:results].each_with_index do |result, i|
      puts "\n#{i + 1}. #{result[:title]}"
      puts "   URL: #{result[:url]}"
      puts "   Description: #{result[:description][0..100]}..." if result[:description]
    end
  end

  # Test news search if available
  if results[:news] && results[:news][:results] && !results[:news][:results].empty?
    puts "\n📰 News results found: #{results[:news][:results].length}"
    results[:news][:results].first(2).each_with_index do |news, i|
      puts "#{i + 1}. #{news[:title]} (#{news[:meta_tag]})"
    end
  end

  # Show raw response structure
  puts "\n📊 Response structure:"
  puts "Available sections: #{results.keys.join(', ')}"

  # Test different query
  puts "\n🔍 Testing search: 'Rails 8 features'"
  rails_results = client.search(q: "Rails 8 features", count: 2)
  puts "✅ Second search successful!"
  puts "Found #{rails_results.dig(:web, :results)&.length || 0} results"

  puts "\n🎉 All tests passed!"
rescue BraveSearch::AuthenticationError => e
  puts "❌ Authentication failed: #{e.message}"
  puts "Check your API key at https://brave.com/search/api/"
rescue BraveSearch::RateLimitError => e
  puts "❌ Rate limit exceeded: #{e.message}"
rescue BraveSearch::QuotaExceededError => e
  puts "❌ Quota exceeded: #{e.message}"
rescue StandardError => e
  puts "❌ Error: #{e.message}"
  puts "Class: #{e.class}"
  puts e.backtrace.first(3) if ENV["DEBUG"]
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/brave_search"

# Basic usage
puts "BraveSearch Ruby Gem Example"
puts "=" * 40

# Configure
BraveSearch.configure do |config|
  config.api_key = ENV["BRAVE_API_KEY"] || "your_api_key_here"
  config.timeout = 30
end

begin
  BraveSearch::Client.new
  puts "Client initialized successfully!"

  # NOTE: This will fail without a real API key
  # results = client.search(q: "ruby programming", count: 5)
  # puts "Found #{results[:web][:results].length} results"
rescue BraveSearch::AuthenticationError => e
  puts "Error: #{e.message}"
  puts "Set BRAVE_API_KEY environment variable with your API key from https://brave.com/search/api/"
rescue StandardError => e
  puts "Error: #{e.message}"
end

puts "\nTo use with a real API key:"
puts "export BRAVE_API_KEY=your_key_here"
puts "ruby example.rb"

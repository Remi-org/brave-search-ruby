# BraveSearch Ruby Gem

Ruby client for the Brave Search API with Rails 8 integration, Ruby 3+ pattern matching, and async support.

## Features

- 🔍 **Multiple Search Types**: Web, news, video, image, suggest, and spellcheck
- ⚡ **Async Support**: Concurrent searches using Ruby 3+ Fiber.schedule
- 🎯 **Pattern Matching**: Ruby 3+ pattern matching support for results
- 🚆 **Rails 8 Integration**: Automatic configuration with Rails credentials
- 🧪 **Comprehensive Testing**: RSpec tests with WebMock
- 💎 **Modern Ruby**: Requires Ruby 3.0+ for modern features

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brave_search'
```

And then execute:

    $ bundle install

## Usage

### Basic Usage

```ruby
client = BraveSearch::Client.new(api_key: 'your_api_key')
results = client.search(q: 'ruby programming', count: 10)

# Results wrapper with convenience methods
puts results.web_results.first[:title]  
puts "Found #{results.count} total results"
```

### Multiple Search Types

```ruby
# Different search types
web_results = client.search(q: 'ruby programming')
news_results = client.news_search(q: 'ruby news')  
video_results = client.video_search(q: 'ruby tutorials')
image_results = client.image_search(q: 'ruby logo')

# Suggestions and spellcheck
suggestions = client.suggest(q: 'ruby prog')
spelling = client.spellcheck(q: 'rubyy')
```

### Ruby 3+ Pattern Matching

```ruby
results = client.search(q: 'ruby programming')

case results
in { web: { results: [first, *rest] }, query: { original: String => query } }
  puts "Found #{rest.length + 1} results for: '#{query}'"
  puts "Top result: #{first[:title]}"
in { web: { results: [] } }
  puts "No results found"
else
  puts "Unexpected response"
end
```

### Async Support

```ruby
require 'async'

async_client = BraveSearch::AsyncClient.new

# Single async search
Async do
  result = async_client.search(q: 'ruby programming').wait
  puts result.web_results.first[:title]
end

# Concurrent searches
Async do
  results = async_client.concurrent_search([
    'ruby programming',
    'rails framework',
    'async ruby'
  ]).wait
  
  results.each { |r| puts "Found #{r.count} results" }
end
```

### Rails Integration

1. Install the initializer:

```bash
rails generate brave_search:install
```

2. Add your API key to Rails credentials:

```bash
rails credentials:edit
```

Add:
```yaml
brave_api_key: your_api_key_here
```

3. Use in your Rails app:

```ruby
client = BraveSearch::Client.new
results = client.search(q: 'ruby on rails')
```

## Configuration

```ruby
BraveSearch.configure do |config|
  config.api_key = 'your_api_key'
  config.timeout = 30
  config.retry_attempts = 3
end
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
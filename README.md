# MetrifoxSDK Ruby Gem

A Ruby SDK for interacting with the Metrifox platform API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metrifox-sdk'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install metrifox-sdk
```

## Usage

### Configuration

```ruby
require 'metrifox-sdk'

# Initialize with configuration
MetrifoxSDK.init({ api_key: "your-api-key"})

# Or set environment variable
ENV["METRIFOX_API_KEY"] = "your-api-key"
METRIFOX_SDK = MetrifoxSDK.init
```

### Access Control

```ruby
# Check feature access
response = METRIFOX_SDK.usages.check_access({
  feature_key: "premium_feature",
  customer_key: "customer_123"
})

puts response["can_access"] # true/false
```

### Usage Tracking

```ruby
# Record usage event
response = METRIFOX_SDK.usages.record_usage({
  customer_key: "customer_123",
  event_name: "api_call",
  amount: 1
})
```

### Customer Management

```ruby
# Create customer
customer_data = {
  customer_key: "customer_123",
  customer_type: "BUSINESS",
  primary_email: "customer@example.com",
  legal_name: "Acme Corp",
  display_name: "ACME"
}

response = METRIFOX_SDK.customers.create(customer_data)

# Update customer
update_data = {
  display_name: "ACME Corporation",
  website_url: "https://acme.com"
}

response = METRIFOX_SDK.customers.update("customer_123", update_data)

# Get customer
response = METRIFOX_SDK.customers.get_customer({ customer_key: "customer_123" })

# Get customer details
response = METRIFOX_SDK.customers.get_details({ customer_key: "customer_123" })

# List customers
response = MetrifoxSDK.customers.list

# List customers with pagination
response = MetrifoxSDK.customers.list({ page: 2, per_page: 10 })

# List customers with filters
response = MetrifoxSDK.customers.list({ 
  search_term: "TechStart",
  customer_type: "BUSINESS",
  date_created: "2025-09-01"
})

# List customers with combined pagination and filters
response = MetrifoxSDK.customers.list({ 
  page: 1,
  per_page: 5,
  search_term: "John",
  customer_type: "INDIVIDUAL"
})

# Delete customer
response = MetrifoxSDK.customers.delete_customer({ customer_key: "customer_123" })

```

### CSV Upload

```ruby
# Upload customers via CSV
response = METRIFOX_SDK.customers.upload_csv("/path/to/customers.csv")

puts response["data"]["total_customers"]
puts response["data"]["successful_upload_count"]
```

### Using Client Instance

```ruby
client = MetrifoxSDK::Client.new({
  api_key: "your-api-key"
})

response = client.usages.check_access({
  feature_key: "premium_feature",
  customer_key: "customer_123"
})
```

## Type Safety with Structs

The SDK provides structured types for better type safety:

```ruby
# Using structured request objects
access_request = MetrifoxSDK::Types::AccessCheckRequest.new(
  feature_key: "premium_feature",
  customer_key: "customer_123"
)

response = MetrifoxSDK.usages.check_access(access_request)

# Customer creation with structured data
customer_request = MetrifoxSDK::Types::CustomerCreateRequest.new(
  customer_key: "customer_123",
  customer_type: MetrifoxSDK::Types::CustomerType::BUSINESS,
  primary_email: "customer@example.com",
  legal_name: "Acme Corp"
)

response = MetrifoxSDK.customers.create(customer_request)
```

## Error Handling

```ruby
begin
  response = METRIFOX_SDK.usages.check_access({
    feature_key: "premium_feature",
    customer_key: "customer_123"
  })
rescue MetrifoxSDK::APIError => e
  puts "API Error: #{e.message}"
rescue MetrifoxSDK::ConfigurationError => e
  puts "Configuration Error: #{e.message}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/metrifox_ruby_sdk.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

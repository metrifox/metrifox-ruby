# MetrifoxSDK Ruby Gem

A Ruby SDK for interacting with the Metrifox platform API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metrifox_sdk'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install metrifox_sdk
```

## Usage

### Configuration

```ruby
require 'metrifox_sdk'

# Initialize with configuration
MetrifoxSDK.init({
  api_key: "your-api-key",
  base_url: "https://metrifox-api.staging.useyala.com/api/v1/",
  web_app_base_url: "https://frontend-v3.staging.useyala.com"
})

# Or set environment variable
ENV["METRIFOX_API_KEY"] = "your-api-key"
MetrifoxSDK.init
```

### Access Control

```ruby
# Check feature access
response = MetrifoxSDK.usages.check_access({
  feature_key: "premium_feature",
  customer_key: "customer_123"
})

puts response["can_access"] # true/false
```

### Usage Tracking

```ruby
# Record usage event
response = MetrifoxSDK.usages.record_usage({
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

response = MetrifoxSDK.customers.create(customer_data)

# Update customer
update_data = {
  display_name: "ACME Corporation",
  website_url: "https://acme.com"
}

response = MetrifoxSDK.customers.update("customer_123", update_data)

# Get customer
response = MetrifoxSDK.customers.get_customer({ customer_key: "customer_123" })

# Get customer details
response = MetrifoxSDK.customers.get_details({ customer_key: "customer_123" })

# Delete customer
response = MetrifoxSDK.delete_customer({ customer_key: "customer_123" })
```

### CSV Upload

```ruby
# Upload customers via CSV
response = MetrifoxSDK.customers.upload_csv("/path/to/customers.csv")

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
  response = MetrifoxSDK.usages.check_access({
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
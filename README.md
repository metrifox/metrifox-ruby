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
METRIFOX_SDK = MetrifoxSDK.init({ api_key: "your-api-key"})

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

puts response["data"]["can_access"] # true/false
```

> Access checks are now served by the Metrifox Meter service (`https://api-meter.metrifox.com`).
Example response payload:

```json
{
  "data": {
    "customer_key": "cust-mit7k5v8obzs",
    "feature_key": "feature_seats",
    "requested_quantity": 1,
    "can_access": true,
    "unlimited": false,
    "balance": 4,
    "used_quantity": 0,
    "entitlement_active": true,
    "prepaid": false,
    "wallet_balance": 0,
    "message": "Feature found"
  }
}
```

### Usage Tracking

```ruby
# Basic usage recording
response = METRIFOX_SDK.usages.record_usage({
  customer_key: "customer_123",
  event_name: "api_call",
  amount: 1,
  event_id: "evt_12345", # required idempotency key
  timestamp: (Time.now.to_f * 1000).to_i # recommended (milliseconds)
})
puts response["message"] # "Event received"
puts response["data"]["quantity"] # 1
```

The usage event endpoint now returns a simple payload with the recorded `data` and a `message` confirming the event reception.

> You can send either an `event_name` or a `feature_key` when recording usage events.

```ruby
# Advanced usage recording with additional fields
response = METRIFOX_SDK.usages.record_usage({
  customer_key: "customer_123",
  event_name: "api_call", # Or use feature_key
  amount: 1,
  event_id: "event_uuid_123", # required idempotency key
  credit_used: 5,
  timestamp: (Time.now.to_f * 1000).to_i,
  metadata: {
    source: "web_app",
    feature: "premium_search"
  }
})

# Using structured request object
usage_request = MetrifoxSDK::Types::UsageEventRequest.new(
  customer_key: "customer_123",
  feature_key: "feat_my_feat_234", # OR use event_name
  amount: 1,
  credit_used: 5,
  event_id: "event_uuid_123",
  timestamp: (Time.now.to_f * 1000).to_i,
  metadata: { source: "mobile_app" }
)

response = METRIFOX_SDK.usages.record_usage(usage_request)
```

Sample response body:

```json
{
  "data": {
    "customer_key": "cust-mit7k5v8obzs",
    "quantity": 1,
    "feature_key": "feature_job_posts"
  },
  "message": "Event received"
}
```

### Customer Management

```ruby
# Create customer (customer_key is REQUIRED)
customer_data = {
  customer_key: "customer_123",  # Required - unique identifier for the customer
  customer_type: "BUSINESS",
  primary_email: "customer@example.com",
  legal_name: "Acme Corp",
  display_name: "ACME"
}

response = METRIFOX_SDK.customers.create(customer_data)

# Update customer (customer_key cannot be changed and is passed as a parameter)
update_data = {
  display_name: "ACME Corporation",
  website_url: "https://acme.com"
  # Note: customer_key is NOT included here - it's immutable
}

response = METRIFOX_SDK.customers.update("customer_123", update_data)

# Get customer
response = METRIFOX_SDK.customers.get_customer({ customer_key: "customer_123" })

# Get customer details
response = METRIFOX_SDK.customers.get_details({ customer_key: "customer_123" })

# Check for an active subscription
has_active_subscription = MetrifoxSDK.customers.has_active_subscription?(customer_key: "customer_123")
puts has_active_subscription # true or false

# List customers
response = METRIFOX_SDK.customers.list

# List customers with pagination
response = METRIFOX_SDK.customers.list({ page: 2, per_page: 10 })

# List customers with filters
response = METRIFOX_SDK.customers.list({ 
  search_term: "TechStart",
  customer_type: "BUSINESS",
  date_created: "2025-09-01"
})

# List customers with combined pagination and filters
response = METRIFOX_SDK.customers.list({ 
  page: 1,
  per_page: 5,
  search_term: "John",
  customer_type: "INDIVIDUAL"
})

# Delete customer
response = METRIFOX_SDK.customers.delete_customer({ customer_key: "customer_123" })

```

### Bulk Create Customers

Create multiple customers in a single API call:

```ruby
result = METRIFOX_SDK.customers.bulk_create({
  customers: [
    {
      customer_key: "customer_001",
      customer_type: "BUSINESS",
      primary_email: "contact@acme.com",
      legal_name: "Acme Corp",
      display_name: "Acme"
    },
    {
      customer_key: "customer_002",
      customer_type: "INDIVIDUAL",
      primary_email: "jane@example.com",
      first_name: "Jane",
      last_name: "Doe"
    }
  ]
})

puts result["data"]["total"]
puts result["data"]["successful_count"]
puts result["data"]["failed_count"]
```

### CSV Upload

```ruby
# Upload customers via CSV
response = METRIFOX_SDK.customers.upload_csv("/path/to/customers.csv")

puts response["data"]["total_customers"]
puts response["data"]["successful_upload_count"]
```

### Checkout URL Generation

```ruby
# Basic checkout URL generation
checkout_url = METRIFOX_SDK.checkout.url({
  offering_key: "your_offering_key"
})

# With optional billing interval
checkout_url = METRIFOX_SDK.checkout.url({
  offering_key: "your_offering_key",
  billing_interval: "monthly"
})

# With customer key for pre-filled checkout
checkout_url = METRIFOX_SDK.checkout.url({
  offering_key: "your_offering_key",
  billing_interval: "monthly",
  customer_key: "customer_123"
})

# Using structured config object
checkout_config = MetrifoxSDK::Types::CheckoutConfig.new(
  offering_key: "your_offering_key",
  billing_interval: "monthly",
  customer_key: "customer_123"
)

checkout_url = METRIFOX_SDK.checkout.url(checkout_config)
```

### Subscriptions

```ruby
# Get billing history for a subscription
response = METRIFOX_SDK.subscriptions.get_billing_history("subscription_uuid")
puts response["data"]
```

```ruby
# Get entitlements summary for a subscription
response = METRIFOX_SDK.subscriptions.get_entitlements_summary("subscription_uuid")
puts response["data"]
```

```ruby
# Get entitlements usage for a subscription
response = METRIFOX_SDK.subscriptions.get_entitlements_usage("subscription_uuid")
puts response["data"]
```

### Bulk Assign Plan

Assign a plan to multiple customers at once:

```ruby
result = METRIFOX_SDK.subscriptions.bulk_assign_plan(
  customer_keys: ["customer_001", "customer_002"],
  plan_key: "pro-plan",
  billing_interval: "monthly",          # optional
  currency_code: "USD",                 # optional
  items: [                              # optional: credit/feature quantities
    { credit_key: "api_credits", quantity: 500 }
  ],
  skip_invoice: false                   # optional
)

puts result["data"]["succeeded"]  # Array of successful assignments
puts result["data"]["failed"]     # Array of failures with error details
```

### Using Client Instance

```ruby

response = METRIFOX_SDK.usages.check_access({
  feature_key: "premium_feature",
  customer_key: "customer_123"
})
```

## Type Safety with Structs

The SDK exposes lightweight structs for the usage and checkout helpers when you want a bit more structure:

```ruby
# Usage events (event_id required for idempotency)
usage_request = MetrifoxSDK::Types::UsageEventRequest.new(
  customer_key: "customer_123",
  feature_key: "feature_seats",
  amount: 1,
  event_id: "event_uuid_123",
  timestamp: (Time.now.to_f * 1000).to_i,
  metadata: { source: "mobile_app" }
)

response = METRIFOX_SDK.usages.record_usage(usage_request)

# Checkout configuration
checkout_config = MetrifoxSDK::Types::CheckoutConfig.new(
  offering_key: "premium_plan",
  billing_interval: "monthly",
  customer_key: "customer_123"
)

checkout_url = METRIFOX_SDK.checkout.url(checkout_config)
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

## SSL Certificate Handling

The SDK configures a custom `OpenSSL::X509::Store` with system default certificate paths for all HTTPS requests. This ensures reliable SSL connections across different Ruby and OpenSSL versions, including environments where strict CRL (Certificate Revocation List) checking may cause verification failures.

No additional configuration is needed — SSL is handled automatically when making API calls.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/metrifox_ruby_sdk.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

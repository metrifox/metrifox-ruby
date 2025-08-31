# spec/spec_helper.rb
require "bundler/setup"

# Force the correct load path
lib_path = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

# Load directly without letting bundler interfere
load File.join(lib_path, 'metrifox_sdk.rb')

require "webmock/rspec"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  WebMock.disable_net_connect!

  # Reset environment variables after each test
  config.after(:each) do
    ENV.delete("METRIFOX_API_KEY") if ENV["METRIFOX_API_KEY"]&.start_with?("test-")
  end
end

# Helper method to create test CSV content
def create_test_csv_content
  "customer_key,primary_email,customer_type,legal_name\n" \
    "customer_001,john@example.com,INDIVIDUAL,John Doe\n" \
    "customer_002,jane@example.com,BUSINESS,Jane Corp\n" \
    "customer_003,bob@example.com,INDIVIDUAL,Bob Smith\n"
end
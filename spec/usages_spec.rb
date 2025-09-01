require_relative '../lib/metrifox_sdk/usages/module'
require 'spec_helper'
require 'webmock/rspec'
require 'tempfile'


RSpec.describe MetrifoxSDK::Usages::Module do
  let(:api_key) { "test-api-key" }
  let(:base_url) { "https://api.example.com/api/v1/" }
  let(:client) do
    MetrifoxSDK::Client.new(
      api_key: api_key,
      base_url: base_url
    )
  end
  let(:usages_module) { client.usages }
  let(:customer_key) { "test_customer_123" }
  let(:feature_key) { "premium_feature" }

  before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  describe "#check_access" do
    let(:access_request) do
      {
        feature_key: feature_key,
        customer_key: customer_key
      }
    end

    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Access check completed",
        "meta" => {},
        "data" => {
          "can_access" => true,
          "customer_id" => "8cd3bde1-96ca-4f01-b015-aad9ce861e91",
          "feature_key" => feature_key,
          "required_quantity" => 1,
          "used_quantity" => 5,
          "included_usage" => 100,
          "next_reset_at" => "2025-09-01T00:00:00.000Z",
          "quota" => 100,
          "unlimited" => false,
          "carryover_quantity" => 0,
          "balance" => 95
        },
        "errors" => {}
      }
    end

    it "checks access successfully" do
      stub_request(:get, "#{base_url}usage/access")
        .with(
          query: {
            feature_key: feature_key,
            customer_key: customer_key
          },
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = usages_module.check_access(access_request)
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(200)
      expect(result["data"]["can_access"]).to be true
      expect(result["data"]["feature_key"]).to eq(feature_key)
      expect(result["data"]["balance"]).to eq(95)
    end

    it "handles access denied" do
      denied_response = {
        "statusCode" => 200,
        "message" => "Access check completed",
        "meta" => {},
        "data" => {
          "can_access" => false,
          "customer_id" => "8cd3bde1-96ca-4f01-b015-aad9ce861e91",
          "feature_key" => feature_key,
          "required_quantity" => 1,
          "used_quantity" => 100,
          "included_usage" => 100,
          "quota" => 100,
          "unlimited" => false,
          "balance" => 0
        },
        "errors" => {}
      }

      stub_request(:get, "#{base_url}usage/access")
        .with(query: { feature_key: feature_key, customer_key: customer_key })
        .to_return(
          status: 200,
          body: denied_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = usages_module.check_access(access_request)
      expect(result["data"]["can_access"]).to be false
      expect(result["data"]["balance"]).to eq(0)
    end

    it "validates API key is not empty" do
      client_with_empty_key = MetrifoxSDK::Client.new(api_key: "")
      usages_module_empty_key = client_with_empty_key.usages

      expect { usages_module_empty_key.check_access(access_request) }
        .to raise_error(MetrifoxSDK::ConfigurationError, /API key required/)
    end
  end

  describe "#record_usage" do
    let(:usage_request) do
      {
        customer_key: customer_key,
        event_name: "api_call",
        amount: 3
      }
    end

    let(:expected_response) do
      {
        "statusCode" => 201,
        "message" => "Usage recorded successfully",
        "meta" => {},
        "data" => {
          "event_name" => "api_call",
          "customer_key" => customer_key,
          "amount_recorded" => 3,
          "new_balance" => 92
        },
        "errors" => {}
      }
    end

    it "records usage successfully" do
      stub_request(:post, "#{base_url}usage/events")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          },
          body: {
            customer_key: customer_key,
            event_name: "api_call",
            amount: 3
          }.to_json
        )
        .to_return(
          status: 201,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = usages_module.record_usage(usage_request)
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(201)
      expect(result["data"]["event_name"]).to eq("api_call")
      expect(result["data"]["amount_recorded"]).to eq(3)
    end

    it "defaults amount to 1 when not provided" do
      usage_request_no_amount = {
        customer_key: customer_key,
        event_name: "api_call"
      }

      expected_body = {
        customer_key: customer_key,
        event_name: "api_call",
        amount: 1
      }

      stub_request(:post, "#{base_url}usage/events")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          },
          body: expected_body.to_json
        )
        .to_return(
          status: 201,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = usages_module.record_usage(usage_request_no_amount)
      expect(result["statusCode"]).to eq(201)
    end

    it "handles usage recording errors" do
      error_response = {
        "statusCode" => 400,
        "message" => "Invalid usage data",
        "meta" => {},
        "data" => nil,
        "errors" => {
          "event_name" => ["is required"],
          "amount" => ["must be positive"]
        }
      }

      stub_request(:post, "#{base_url}usage/events")
        .to_return(
          status: 400,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { usages_module.record_usage(usage_request) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to record usage: 400/)
    end

    it "handles quota exceeded" do
      quota_exceeded_response = {
        "statusCode" => 429,
        "message" => "Usage quota exceeded",
        "meta" => {},
        "data" => nil,
        "errors" => {
          "quota" => ["Monthly usage limit reached"]
        }
      }

      stub_request(:post, "#{base_url}usage/events")
        .to_return(
          status: 429,
          body: quota_exceeded_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { usages_module.record_usage(usage_request) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to record usage: 429/)
    end
  end

  describe "#get_tenant_id" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Tenant ID retrieved successfully",
        "meta" => {},
        "data" => {
          "tenant_id" => "tenant_123456789"
        },
        "errors" => {}
      }
    end

    it "fetches tenant ID successfully" do
      stub_request(:get, "#{base_url}auth/get-tenant-id")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = usages_module.get_tenant_id
      expect(result).to eq("tenant_123456789")
    end

    it "handles authentication errors" do
      error_response = {
        "statusCode" => 401,
        "message" => "Unauthorized",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:get, "#{base_url}auth/get-tenant-id")
        .to_return(
          status: 401,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { usages_module.get_tenant_id }
        .to raise_error(MetrifoxSDK::APIError, /Failed to get tenant id: 401/)
    end
  end

  describe "#get_checkout_key" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Checkout settings retrieved successfully",
        "meta" => {},
        "data" => {
          "checkout_username" => "checkout_user_abc123"
        },
        "errors" => {}
      }
    end

    it "fetches checkout key successfully" do
      stub_request(:get, "#{base_url}auth/checkout-username")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = usages_module.get_checkout_key
      expect(result).to eq("checkout_user_abc123")
    end

    it "handles checkout settings not found" do
      error_response = {
        "statusCode" => 404,
        "message" => "Checkout settings not configured",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:get, "#{base_url}auth/checkout-username")
        .to_return(
          status: 404,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { usages_module.get_checkout_key }
        .to raise_error(MetrifoxSDK::APIError, /Failed to get tenant checkout settings: 404/)
    end

    it "validates API key is not empty" do
      client_with_empty_key = MetrifoxSDK::Client.new(api_key: "")
      usages_module_empty_key = client_with_empty_key.usages

      expect { usages_module_empty_key.get_checkout_key }
        .to raise_error(MetrifoxSDK::ConfigurationError, /API key required/)
    end
  end

  describe "module instantiation and caching" do
    it "caches the API instance" do
      api1 = usages_module.send(:api)
      api2 = usages_module.send(:api)
      expect(api1).to be(api2)
    end

    it "has access to client configuration" do
      expect(usages_module.send(:api_key)).to eq(api_key)
      expect(usages_module.send(:base_url)).to eq(base_url)
    end
  end
end

# Integration tests to verify the modular interface works end-to-end
RSpec.describe "MetrifoxSDK Integration" do
  let(:api_key) { "integration-test-key" }
  let(:base_url) { "https://api.example.com/api/v1/" }

  before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  describe "end-to-end usage flow" do
    it "allows chaining operations across modules" do
      # Initialize SDK
      metrifox = MetrifoxSDK.init(api_key: api_key, base_url: base_url)

      # Stub customer creation
      customer_response = {
        "statusCode" => 201,
        "message" => "Customer Created Successfully",
        "data" => { "customer_key" => "test_customer_123" }
      }

      stub_request(:post, "#{base_url}customers/new")
        .to_return(
          status: 201,
          body: customer_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Stub access check
      access_response = {
        "statusCode" => 200,
        "message" => "Access check completed",
        "data" => { "can_access" => true, "balance" => 95 }
      }

      stub_request(:get, "#{base_url}usage/access")
        .to_return(
          status: 200,
          body: access_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Stub usage recording
      usage_response = {
        "statusCode" => 201,
        "message" => "Usage recorded successfully",
        "data" => { "event_name" => "api_call", "amount_recorded" => 1 }
      }

      stub_request(:post, "#{base_url}usage/events")
        .to_return(
          status: 201,
          body: usage_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Test the flow
      customer_result = metrifox.customers.create({
                                                    customer_key: "test_customer_123",
                                                    customer_type: "BUSINESS",
                                                    primary_email: "test@example.com"
                                                  })

      access_result = metrifox.usages.check_access({
                                                     feature_key: "premium_feature",
                                                     customer_key: "test_customer_123"
                                                   })

      usage_result = metrifox.usages.record_usage({
                                                    customer_key: "test_customer_123",
                                                    event_name: "api_call",
                                                    amount: 1
                                                  })

      expect(customer_result["statusCode"]).to eq(201)
      expect(access_result["data"]["can_access"]).to be true
      expect(usage_result["statusCode"]).to eq(201)
    end

    it "maintains consistent error handling across modules" do
      metrifox = MetrifoxSDK.init(api_key: api_key, base_url: base_url)

      # Stub error responses for both modules
      stub_request(:post, "#{base_url}customers/new")
        .to_return(status: 500, body: '{"message": "Internal Server Error"}')

      stub_request(:get, "#{base_url}usage/access")
        .to_return(status: 500, body: '{"message": "Internal Server Error"}')

      expect { metrifox.customers.create({}) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to Create Customer: 500/)

      expect { metrifox.usages.check_access({}) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to check access: 500/)
    end
  end
end
require_relative '../lib/metrifox_sdk/subscriptions/module'
require 'spec_helper'
require 'webmock/rspec'

RSpec.describe MetrifoxSDK::Subscriptions::Module do
  let(:api_key) { "test-api-key" }
  let(:base_url) { "https://api.example.com/api/v1/" }
  let(:client) do
    MetrifoxSDK::Client.new(
      api_key: api_key,
      base_url: base_url
    )
  end
  let(:subscriptions_module) { client.subscriptions }
  let(:subscription_id) { "bf91bb3d-6fbd-43cf-8cbe-00fa3dbbaafb" }

  before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  describe "#get_billing_history" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Billing History Retrieved Successfully",
        "meta" => {},
        "data" => [
          {
            "invoice_id" => "inv_001",
            "amount" => 9900,
            "currency" => "USD",
            "status" => "paid",
            "created_at" => "2025-08-01T00:00:00.000Z"
          },
          {
            "invoice_id" => "inv_002",
            "amount" => 9900,
            "currency" => "USD",
            "status" => "paid",
            "created_at" => "2025-09-01T00:00:00.000Z"
          }
        ],
        "errors" => {}
      }
    end

    it "fetches billing history successfully" do
      stub_request(:get, "#{base_url}subscriptions/#{subscription_id}/billing-history")
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

      result = subscriptions_module.get_billing_history(subscription_id)
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(200)
      expect(result["data"]).to be_an(Array)
      expect(result["data"].length).to eq(2)
    end

    it "handles subscription not found" do
      error_response = {
        "statusCode" => 404,
        "message" => "Subscription not found",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:get, "#{base_url}subscriptions/#{subscription_id}/billing-history")
        .to_return(
          status: 404,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { subscriptions_module.get_billing_history(subscription_id) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to Fetch Billing History: 404/)
    end

    it "validates API key is not empty string" do
      client_with_empty_key = MetrifoxSDK::Client.new(api_key: "")
      sub_module_empty_key = client_with_empty_key.subscriptions

      expect { sub_module_empty_key.get_billing_history(subscription_id) }
        .to raise_error(MetrifoxSDK::ConfigurationError, /API key required/)
    end
  end

  describe "#get_entitlements_summary" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Entitlements Summary Retrieved Successfully",
        "meta" => {},
        "data" => [
          {
            "feature_key" => "api_calls",
            "allowance" => 10000,
            "used" => 3500,
            "remaining" => 6500
          }
        ],
        "errors" => {}
      }
    end

    it "fetches entitlements summary successfully" do
      stub_request(:get, "#{base_url}subscriptions/#{subscription_id}/v2/entitlements-summary")
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

      result = subscriptions_module.get_entitlements_summary(subscription_id)
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(200)
      expect(result["data"]).to be_an(Array)
      expect(result["data"].first["feature_key"]).to eq("api_calls")
    end

    it "handles subscription not found" do
      error_response = {
        "statusCode" => 404,
        "message" => "Subscription not found",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:get, "#{base_url}subscriptions/#{subscription_id}/v2/entitlements-summary")
        .to_return(
          status: 404,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { subscriptions_module.get_entitlements_summary(subscription_id) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to Fetch Entitlements Summary: 404/)
    end
  end

  describe "#get_entitlements_usage" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Entitlements Usage Retrieved Successfully",
        "meta" => {},
        "data" => [
          {
            "feature_key" => "api_calls",
            "purchased" => 10000,
            "included" => 5000,
            "pay_as_you_go" => 0,
            "rollover" => 500,
            "used" => 3500
          }
        ],
        "errors" => {}
      }
    end

    it "fetches entitlements usage successfully" do
      stub_request(:get, "#{base_url}subscriptions/#{subscription_id}/v2/entitlements-usage")
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

      result = subscriptions_module.get_entitlements_usage(subscription_id)
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(200)
      expect(result["data"]).to be_an(Array)
      expect(result["data"].first["feature_key"]).to eq("api_calls")
      expect(result["data"].first["used"]).to eq(3500)
    end

    it "handles subscription not found" do
      error_response = {
        "statusCode" => 404,
        "message" => "Subscription not found",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:get, "#{base_url}subscriptions/#{subscription_id}/v2/entitlements-usage")
        .to_return(
          status: 404,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { subscriptions_module.get_entitlements_usage(subscription_id) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to Fetch Entitlements Usage: 404/)
    end

    it "handles server errors" do
      error_response = {
        "statusCode" => 500,
        "message" => "Internal Server Error",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:get, "#{base_url}subscriptions/#{subscription_id}/v2/entitlements-usage")
        .to_return(
          status: 500,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { subscriptions_module.get_entitlements_usage(subscription_id) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to Fetch Entitlements Usage: 500/)
    end
  end
end

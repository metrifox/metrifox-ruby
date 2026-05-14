require_relative '../lib/metrifox_sdk/checkout/module'
require 'spec_helper'
require 'webmock/rspec'

RSpec.describe MetrifoxSDK::Checkout::Module do
  let(:api_key) { "test-api-key" }
  let(:base_url) { "https://api.example.com/api/v1/" }
  let(:web_app_base_url) { "https://app.example.com" }
  let(:client) do
    MetrifoxSDK::Client.new(
      api_key: api_key,
      base_url: base_url,
      web_app_base_url: web_app_base_url
    )
  end
  let(:checkout_module) { client.checkout }
  let(:checkout_key) { "checkout_user_abc123" }

  before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  describe "#url" do
    let(:checkout_url) { "https://checkout.example.com/checkout/abc123" }

    it "generates basic checkout URL with only offering_key" do
      config = { offering_key: "premium_plan" }

      checkout_response = {
        "statusCode" => 200,
        "message" => "Checkout URL generated successfully",
        "data" => {
          "checkout_url" => checkout_url
        }
      }

      stub_request(:get, "#{base_url}products/offerings/generate-checkout-url?offering_key=premium_plan")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: checkout_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = checkout_module.url(config)

      expect(result).to eq(checkout_url)
    end

    it "generates checkout URL with all parameters" do
      config = {
        offering_key: "premium_plan",
        billing_interval: "monthly",
        customer_key: "customer_123"
      }

      checkout_response = {
        "statusCode" => 200,
        "message" => "Checkout URL generated successfully",
        "data" => {
          "checkout_url" => checkout_url
        }
      }

      stub_request(:get, "#{base_url}products/offerings/generate-checkout-url?offering_key=premium_plan&billing_interval=monthly&customer_key=customer_123")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: checkout_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = checkout_module.url(config)

      expect(result).to eq(checkout_url)
    end

    it "generates checkout URL from CheckoutConfig struct" do
      config = MetrifoxSDK::Types::CheckoutConfig.new(
        offering_key: "premium_plan",
        billing_interval: "monthly",
        customer_key: "customer_123"
      )

      checkout_response = {
        "statusCode" => 200,
        "message" => "Checkout URL generated successfully",
        "data" => {
          "checkout_url" => checkout_url
        }
      }

      stub_request(:get, "#{base_url}products/offerings/generate-checkout-url?offering_key=premium_plan&billing_interval=monthly&customer_key=customer_123")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: checkout_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = checkout_module.url(config)

      expect(result).to eq(checkout_url)
    end

    it "raises error when offering_key is missing" do
      config = { billing_interval: "monthly" }
      
      expect { checkout_module.url(config) }
        .to raise_error(ArgumentError, "offering_key is required")
    end

    it "validates API key is not empty" do
      client_with_empty_key = MetrifoxSDK::Client.new(api_key: "")
      checkout_module_empty_key = client_with_empty_key.checkout

      expect { checkout_module_empty_key.url({ offering_key: "premium_plan" }) }
        .to raise_error(MetrifoxSDK::ConfigurationError, /API key required/)
    end
  end

  describe "#card_collection_url" do
    let(:card_url) { "https://checkout.example.com/card-collection/abc123" }
    let(:card_response) do
      {
        "statusCode" => 200,
        "message" => "Card collection URL generated successfully",
        "data" => { "checkout_url" => card_url }
      }
    end

    it "generates a card collection URL for a subscription" do
      stub_request(:get, "#{base_url}checkout/generate-card-collection-url?subscription_id=sub_uuid_123")
        .with(headers: { 'x-api-key' => api_key })
        .to_return(
          status: 200,
          body: card_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = checkout_module.card_collection_url(subscription_id: "sub_uuid_123")
      expect(result).to eq(card_url)
    end

    it "generates a card collection URL for an order" do
      stub_request(:get, "#{base_url}checkout/generate-card-collection-url?order_id=order_uuid_456")
        .with(headers: { 'x-api-key' => api_key })
        .to_return(
          status: 200,
          body: card_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = checkout_module.card_collection_url(order_id: "order_uuid_456")
      expect(result).to eq(card_url)
    end

    it "raises when neither subscription_id nor order_id is provided" do
      expect { checkout_module.card_collection_url }
        .to raise_error(ArgumentError, /Either subscription_id or order_id is required/)
    end

    it "raises when API returns an empty URL" do
      stub_request(:get, "#{base_url}checkout/generate-card-collection-url?subscription_id=sub_uuid_123")
        .to_return(
          status: 200,
          body: { "data" => { "checkout_url" => "" } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { checkout_module.card_collection_url(subscription_id: "sub_uuid_123") }
        .to raise_error(StandardError, /Card collection URL could not be generated/)
    end

    it "validates API key" do
      client_with_empty_key = MetrifoxSDK::Client.new(api_key: "")
      expect { client_with_empty_key.checkout.card_collection_url(subscription_id: "sub_uuid_123") }
        .to raise_error(MetrifoxSDK::ConfigurationError, /API key required/)
    end
  end
end

# Integration test
RSpec.describe "MetrifoxSDK Checkout Integration" do
  let(:api_key) { "integration-test-key" }
  let(:base_url) { "https://api.example.com/api/v1/" }
  let(:web_app_base_url) { "https://app.example.com" }

  before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  it "allows generating checkout URLs through the main SDK client" do
    metrifox = MetrifoxSDK.init(
      api_key: api_key,
      base_url: base_url,
      web_app_base_url: web_app_base_url
    )

    checkout_response = {
      "statusCode" => 200,
      "message" => "Checkout URL generated successfully",
      "data" => {
        "checkout_url" => "https://checkout.example.com/checkout/integration123"
      }
    }

    stub_request(:get, "#{base_url}products/offerings/generate-checkout-url?offering_key=enterprise_plan&billing_interval=yearly&customer_key=customer_enterprise_123")
      .to_return(
        status: 200,
        body: checkout_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    url = metrifox.checkout.url({
      offering_key: "enterprise_plan",
      billing_interval: "yearly",
      customer_key: "customer_enterprise_123"
    })

    expect(url).to eq("https://checkout.example.com/checkout/integration123")
  end
end
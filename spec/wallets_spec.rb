require_relative '../lib/metrifox_sdk/wallets/module'
require 'spec_helper'
require 'webmock/rspec'

RSpec.describe MetrifoxSDK::Wallets::Module do
  let(:api_key) { "test-api-key" }
  let(:base_url) { "https://api.example.com/api/v1/" }
  let(:client) { MetrifoxSDK::Client.new(api_key: api_key, base_url: base_url) }
  let(:wallets_module) { client.wallets }
  let(:customer_key) { "test_customer_123" }
  let(:wallet_id) { "wallet_uuid_123" }
  let(:allocation_id) { "alloc_uuid_123" }

  before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  describe "#list" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "data" => [
          {
            "id" => wallet_id,
            "name" => "API Credits",
            "credit_unit_singular" => "credit",
            "credit_unit_plural" => "credits",
            "credit_system_id" => "cs_uuid_123",
            "balance" => 100.0,
            "credit_key" => "api_credits",
            "customer_key" => customer_key,
            "topup_link" => "https://app.metrifox.com/topup/abc"
          }
        ]
      }
    end

    it "lists wallets for a customer" do
      stub_request(:get, "#{base_url}credit_systems/v2/wallets")
        .with(query: { customer_key: customer_key }, headers: { 'x-api-key' => api_key })
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = wallets_module.list(customer_key)
      expect(result).to eq(expected_response)
      expect(result["data"].first["id"]).to eq(wallet_id)
    end

    it "handles API errors" do
      stub_request(:get, "#{base_url}credit_systems/v2/wallets")
        .with(query: { customer_key: customer_key })
        .to_return(status: 500, body: { message: "boom" }.to_json)

      expect { wallets_module.list(customer_key) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to list wallets: 500/)
    end

    it "validates API key" do
      empty_client = MetrifoxSDK::Client.new(api_key: "")
      expect { empty_client.wallets.list(customer_key) }
        .to raise_error(MetrifoxSDK::ConfigurationError, /API key required/)
    end
  end

  describe "#list_credit_allocations" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "data" => [
          {
            "id" => allocation_id,
            "amount" => 50.0,
            "consumed" => 10.0,
            "created_at" => "2026-05-01T10:00:00Z",
            "allocation_type" => "purchased",
            "order_id" => "order_uuid_1",
            "invoice_id" => "inv_uuid_1",
            "order_number" => "ORD-001",
            "valid_until" => "2027-05-01T10:00:00Z",
            "transactions" => []
          }
        ]
      }
    end

    it "lists credit allocations for a wallet" do
      stub_request(:get, "#{base_url}credit_systems/v2/wallets/#{wallet_id}/credit-allocations")
        .with(headers: { 'x-api-key' => api_key })
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = wallets_module.list_credit_allocations(wallet_id)
      expect(result["data"].first["id"]).to eq(allocation_id)
    end

    it "lists credit allocations filtered by status" do
      stub_request(:get, "#{base_url}credit_systems/v2/wallets/#{wallet_id}/credit-allocations")
        .with(query: { status: "active" }, headers: { 'x-api-key' => api_key })
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = wallets_module.list_credit_allocations(wallet_id, status: "active")
      expect(result["data"].first["allocation_type"]).to eq("purchased")
    end

    it "handles API errors" do
      stub_request(:get, "#{base_url}credit_systems/v2/wallets/#{wallet_id}/credit-allocations")
        .to_return(status: 404, body: { message: "Not found" }.to_json)

      expect { wallets_module.list_credit_allocations(wallet_id) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to list credit allocations: 404/)
    end
  end

  describe "#get_credit_allocation" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "data" => {
          "id" => allocation_id,
          "amount" => 100.0,
          "consumed" => 25.0,
          "created_at" => "2026-05-01T10:00:00Z",
          "allocation_type" => "purchased",
          "transactions" => [
            {
              "id" => "txn_1",
              "amount" => 25.0,
              "created_at" => "2026-05-02T11:00:00Z",
              "quantity" => 25.0,
              "event_name" => "api_call",
              "usage_event_id" => "evt_uuid_1"
            }
          ]
        }
      }
    end

    it "gets a single credit allocation with transactions" do
      stub_request(:get, "#{base_url}credit_systems/v2/credit-allocations/#{allocation_id}")
        .with(headers: { 'x-api-key' => api_key })
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = wallets_module.get_credit_allocation(allocation_id)
      expect(result).to eq(expected_response)
      expect(result["data"]["transactions"].length).to eq(1)
    end

    it "handles API errors" do
      stub_request(:get, "#{base_url}credit_systems/v2/credit-allocations/#{allocation_id}")
        .to_return(status: 404, body: { message: "Not found" }.to_json)

      expect { wallets_module.get_credit_allocation(allocation_id) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to get credit allocation: 404/)
    end
  end
end

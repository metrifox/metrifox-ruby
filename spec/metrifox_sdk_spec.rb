require 'spec_helper'

RSpec.describe MetrifoxSDK do
  it "has a version number" do
    expect(MetrifoxSdk::VERSION).not_to be nil
  end

  describe ".init" do
    it "creates a default client with API key" do
      expect(MetrifoxSDK).to respond_to(:init)
      client = MetrifoxSDK.init(api_key: "test-key")
      expect(client).to be_a(MetrifoxSDK::Client)
      expect(client.api_key).to eq("test-key")
    end

    it "creates a client with custom base URL" do
      client = MetrifoxSDK.init(
        api_key: "test-key",
        base_url: "https://custom.api.com/v1/"
      )
      expect(client.base_url).to eq("https://custom.api.com/v1/")
    end

    it "creates a client with custom web app base URL" do
      client = MetrifoxSDK.init(
        api_key: "test-key",
        web_app_base_url: "https://custom.webapp.com"
      )
      expect(client.web_app_base_url).to eq("https://custom.webapp.com")
    end

    it "creates a client with all custom configurations" do
      client = MetrifoxSDK.init(
        api_key: "custom-key",
        base_url: "https://staging.api.com/v1/",
        web_app_base_url: "https://staging.webapp.com"
      )

      expect(client.api_key).to eq("custom-key")
      expect(client.base_url).to eq("https://staging.api.com/v1/")
      expect(client.web_app_base_url).to eq("https://staging.webapp.com")
    end

    it "uses environment variable for API key when not provided" do
      allow(MetrifoxSdk::UtilMethods).to receive(:load_dotenv)
      allow(ENV).to receive(:[]).with("METRIFOX_API_KEY").and_return("env-api-key")

      client = MetrifoxSDK.init
      expect(client.api_key).to eq("env-api-key")
    end

    it "provides access to customers module" do
      client = MetrifoxSDK.init(api_key: "test-key")
      expect(client.customers).to be_a(MetrifoxSDK::Customers::Module)
    end

    it "provides access to usages module" do
      client = MetrifoxSDK.init(api_key: "test-key")
      expect(client.usages).to be_a(MetrifoxSDK::Usages::Module)
    end

    it "returns the same module instance on multiple calls" do
      client = MetrifoxSDK.init(api_key: "test-key")
      customers1 = client.customers
      customers2 = client.customers
      expect(customers1).to be(customers2)
    end

    it "allows modules to access client configuration" do
      client = MetrifoxSDK.init(
        api_key: "test-key",
        base_url: "https://custom.api.com/v1/"
      )

      customers_module = client.customers
      expect(customers_module.send(:api_key)).to eq("test-key")
      expect(customers_module.send(:base_url)).to eq("https://custom.api.com/v1/")
    end
  end

  describe "module integration" do
    let(:client) { MetrifoxSDK.init(api_key: "test-key") }

    it "customers module responds to expected methods" do
      customers = client.customers
      expect(customers).to respond_to(:create)
      expect(customers).to respond_to(:update)
      expect(customers).to respond_to(:get)
      expect(customers).to respond_to(:get_details)
      expect(customers).to respond_to(:delete)
      expect(customers).to respond_to(:upload_csv)
    end

    it "usages module responds to expected methods" do
      usages = client.usages
      expect(usages).to respond_to(:check_access)
      expect(usages).to respond_to(:record_usage)
      expect(usages).to respond_to(:get_tenant_id)
      expect(usages).to respond_to(:get_checkout_key)
    end
  end
end
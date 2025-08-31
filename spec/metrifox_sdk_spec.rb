require 'spec_helper'

RSpec.describe MetrifoxSDK do
  it "has a version number" do
    expect(MetrifoxSdk::VERSION).not_to be nil
  end

  describe ".init" do
    it "creates a default client with API key" do
      expect(MetrifoxSDK).to respond_to(:init)
      client = MetrifoxSDK.init(api_key: "test-key")
      expect(client).to be_a(MetrifoxSdk::Client)
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
      allow(ENV).to receive(:[]).with("METRIFOX_API_KEY").and_return("env-api-key")

      client = MetrifoxSDK.init
      expect(client.api_key).to eq("env-api-key")
    end
  end
end
module MetrifoxSDK
  class BaseModule
    attr_reader :client

    def initialize(client)
      @client = client
    end

    protected

    def api_key
      @client.api_key
    end

    def base_url
      @client.base_url
    end

    def validate_api_key!
      if api_key.nil? || api_key.empty?
        raise ConfigurationError, "API key required. Set it via config or METRIFOX_API_KEY environment variable."
      end
    end
  end

  class ConfigurationError < StandardError; end
end
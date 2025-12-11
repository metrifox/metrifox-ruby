require_relative './util_methods'

module MetrifoxSDK
  class Client
    include MetrifoxSDK::UtilMethods

    DEFAULT_BASE_URL = "https://api.metrifox.com/api/v1/".freeze
    DEFAULT_WEB_APP_BASE_URL = "https://app.metrifox.com".freeze
    METER_SERVICE_BASE_URL = "https://api-meter.metrifox.com/".freeze

    attr_reader :config, :api_key, :base_url, :web_app_base_url, :meter_service_base_url

    def initialize(config = {})
      @config = config
      @api_key = config[:api_key] || get_api_key_from_environment
      @base_url = config[:base_url] || DEFAULT_BASE_URL
      @web_app_base_url = config[:web_app_base_url] || DEFAULT_WEB_APP_BASE_URL
      @meter_service_base_url = METER_SERVICE_BASE_URL
    end

    def customers
      @customers ||= Customers::Module.new(self)
    end

    def usages
      @usages ||= Usages::Module.new(self)
    end

    def checkout
      @checkout ||= Checkout::Module.new(self)
    end

    private

    def get_api_key_from_environment
      MetrifoxSDK::UtilMethods.load_dotenv
      ENV["METRIFOX_API_KEY"] || ""
    end
  end
end

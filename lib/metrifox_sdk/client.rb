require_relative './util_methods'

module MetrifoxSDK
  class Client
    include MetrifoxSDK::UtilMethods

    attr_reader :config, :api_key, :base_url, :web_app_base_url

    def initialize(config = {})
      @config = config
      @api_key = config[:api_key] || get_api_key_from_environment
      @base_url = config[:base_url] || "https://api.metrifox.com/api/v1/"
      @web_app_base_url = config[:web_app_base_url] || "https://app.metrifox.com"
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

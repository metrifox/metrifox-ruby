require_relative "customers/api"
require_relative "usages/api"
require_relative "util"

module MetrifoxSdk
  class ConfigurationError < StandardError; end
  class Client
    include MetrifoxSdk::UtilMethods
    attr_accessor :api_key, :base_url, :web_app_base_url

    def initialize(config = {})
      @api_key = config[:api_key] || get_api_key_from_environment
      @base_url = config[:base_url] || "https://metrifox-api.staging.useyala.com/api/v1/"
      @web_app_base_url = config[:web_app_base_url] || "https://frontend-v3.staging.useyala.com"

      # Only raise error if API key is needed for actual API calls
      # This allows initialization without API key for testing
      @api_key_required = !(@api_key.nil? || @api_key.empty?)
    end

    def check_access(request_payload)
      validate_api_key!
      usages_api.fetch_access(@base_url, @api_key, request_payload)
    end

    def record_usage(request_payload)
      validate_api_key!
      usages_api.fetch_usage(
        @base_url,
        @api_key,
        request_payload
      )
    end

    def get_tenant_id
      validate_api_key!
      usages_api.fetch_tenant_id(@base_url, @api_key)
    end

    def get_checkout_key
      validate_api_key!
      usages_api.fetch_checkout_key(@base_url, @api_key)
    end

    def create_customer(request_payload)
      validate_api_key!
      customers_api.customer_create_request(
        @base_url,
        @api_key,
        request_payload
      )
    end

    def update_customer(customer_key, request_payload)
      validate_api_key!
      customers_api.customer_update_request(
        @base_url,
        @api_key,
        customer_key,
        request_payload
      )
    end

    def get_customer(request_payload)
      validate_api_key!
      customers_api.customer_get_request(
        @base_url,
        @api_key,
        request_payload
      )
    end

    def get_customer_details(request_payload)
      validate_api_key!
      customers_api.customer_details_get_request(
        @base_url,
        @api_key,
        request_payload
      )
    end

    def delete_customer(request_payload)
      validate_api_key!
      customers_api.customer_delete_request(
        @base_url,
        @api_key,
        request_payload
      )
    end

    def upload_customers_csv(file_path)
      validate_api_key!
      customers_api.upload_customers_csv(
        @base_url,
        @api_key,
        file_path
      )
    end

    def set_api_key(api_key)
      @api_key = api_key
    end

    def set_base_url(base_url)
      @base_url = base_url
    end

    private

    def get_api_key_from_environment
      UtilMethods.load_dotenv
      ENV["METRIFOX_API_KEY"] || ""
    end

    def validate_api_key!
      if @api_key.nil? || @api_key.empty?
        raise ConfigurationError, "API key required. Set it via config or METRIFOX_API_KEY environment variable."
      end
    end

    def usages_api
      @usages_api ||= MetrifoxSdk::Usages::API.new
    end

    def customers_api
      @customers_api ||= MetrifoxSdk::Customers::API.new
    end
  end
end
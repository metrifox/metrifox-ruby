require_relative "api"
require_relative "../base_module"

module MetrifoxSDK
  module Customers
    class Module < BaseModule
      def create(request_payload)
        validate_api_key!
        api.customer_create_request(base_url, api_key, request_payload)
      end

      def update(customer_key, request_payload)
        validate_api_key!
        api.customer_update_request(base_url, api_key, customer_key, request_payload)
      end

      def get_customer(request_payload)
        validate_api_key!
        api.customer_get_request(base_url, api_key, request_payload)
      end

      def get(request_payload)
        get_customer(request_payload)
      end

      def get_details(request_payload)
        validate_api_key!
        api.customer_details_get_request(base_url, api_key, request_payload)
      end

      def has_active_subscription?(customer_key:)
        validate_api_key!
        result = api.customer_active_subscription_request(base_url, api_key, customer_key)
        data = result["data"] || {}
        data["has_active_subscription"]
      end

      def delete_customer(request_payload)
        validate_api_key!
        api.customer_delete_request(base_url, api_key, request_payload)
      end

      def delete(request_payload)
        delete_customer(request_payload)
      end

      def list(request_payload = {})
        validate_api_key!
        api.customer_list_request(base_url, api_key, request_payload)
      end

      def upload_csv(file_path)
        validate_api_key!
        api.upload_customers_csv(base_url, api_key, file_path)
      end

      private

      def api
        @api ||= API.new
      end
    end
  end
end

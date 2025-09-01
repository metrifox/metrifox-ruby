require_relative "api"
require_relative "../base_module"

module MetrifoxSDK
  module Usages
    class Module < BaseModule
      def check_access(request_payload)
        validate_api_key!
        api.fetch_access(base_url, api_key, request_payload)
      end

      def record_usage(request_payload)
        validate_api_key!
        api.fetch_usage(base_url, api_key, request_payload)
      end

      def get_tenant_id
        validate_api_key!
        api.fetch_tenant_id(base_url, api_key)
      end

      def get_checkout_key
        validate_api_key!
        api.fetch_checkout_key(base_url, api_key)
      end

      private

      def api
        @api ||= API.new
      end
    end
  end
end
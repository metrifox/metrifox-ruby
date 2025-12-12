require_relative "api"
require_relative "../base_module"

module MetrifoxSDK
  module Usages
    class Module < BaseModule
      def check_access(request_payload)
        validate_api_key!
        api.fetch_access(meter_service_base_url, api_key, request_payload)
      end

      def record_usage(request_payload)
        validate_api_key!
        api.record_usage(meter_service_base_url, api_key, request_payload)
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

      def meter_service_base_url
        client.respond_to?(:meter_service_base_url) ? client.meter_service_base_url : base_url
      end

      def api
        @api ||= API.new
      end
    end
  end
end

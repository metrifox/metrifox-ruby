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

      def list_events(customer_key: nil, feature_key: nil, page: nil, per_page: nil)
        validate_api_key!
        query_params = {}
        query_params[:customer_key] = customer_key if customer_key
        query_params[:feature_key] = feature_key if feature_key
        query_params[:page] = page if page
        query_params[:per_page] = per_page if per_page
        api.list_events(meter_service_base_url, api_key, query_params)
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

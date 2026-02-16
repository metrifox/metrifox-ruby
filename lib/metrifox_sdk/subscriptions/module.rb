require_relative "api"
require_relative "../base_module"

module MetrifoxSDK
  module Subscriptions
    class Module < BaseModule
      def get_billing_history(subscription_id)
        validate_api_key!
        api.billing_history_request(base_url, api_key, subscription_id)
      end

      def get_entitlements_summary(subscription_id)
        validate_api_key!
        api.entitlements_summary_request(base_url, api_key, subscription_id)
      end

      def get_entitlements_usage(subscription_id)
        validate_api_key!
        api.entitlements_usage_request(base_url, api_key, subscription_id)
      end

      private

      def api
        @api ||= API.new
      end
    end
  end
end

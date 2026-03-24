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

      def bulk_assign_plan(customer_keys:, plan_key:, billing_interval: nil, currency_code: nil, items: nil, skip_invoice: nil)
        validate_api_key!
        request_payload = {
          customer_keys: customer_keys,
          plan_key: plan_key,
          billing_interval: billing_interval,
          currency_code: currency_code,
          items: items,
          skip_invoice: skip_invoice
        }.compact
        api.bulk_assign_plan_request(base_url, api_key, request_payload)
      end

      private

      def api
        @api ||= API.new
      end
    end
  end
end

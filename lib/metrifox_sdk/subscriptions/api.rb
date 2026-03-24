require "net/http"
require "uri"
require "json"
require_relative "../base_api"

module MetrifoxSDK::Subscriptions
  class API < MetrifoxSDK::BaseApi
    def billing_history_request(base_url, api_key, subscription_id)
      uri = URI.join(base_url, "subscriptions/#{subscription_id}/billing-history")
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to Fetch Billing History")
    end

    def entitlements_summary_request(base_url, api_key, subscription_id)
      uri = URI.join(base_url, "subscriptions/#{subscription_id}/v2/entitlements-summary")
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to Fetch Entitlements Summary")
    end

    def entitlements_usage_request(base_url, api_key, subscription_id)
      uri = URI.join(base_url, "subscriptions/#{subscription_id}/v2/entitlements-usage")
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to Fetch Entitlements Usage")
    end

    def bulk_assign_plan_request(base_url, api_key, request_payload)
      uri = URI.join(base_url, "subscriptions/bulk-assign-plan")
      body = if request_payload.respond_to?(:to_h)
               request_payload.to_h.compact
             elsif request_payload.is_a?(Hash)
               request_payload.compact
             else
               raise ArgumentError, "Invalid request format"
             end
      response = make_request(uri, "POST", api_key, body)
      parse_response(response, "Failed to Bulk Assign Plan")
    end
  end
end

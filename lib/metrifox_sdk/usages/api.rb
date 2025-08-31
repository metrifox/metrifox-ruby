require "net/http"
require "uri"
require "json"
require "mime/types"
require_relative "../base_api"

module MetrifoxSdk::Usages
  class API < MetrifoxSdk::BaseApi
    def fetch_access(base_url, api_key, request_payload)
      uri = URI.join(base_url, "usage/access")
      uri.query = URI.encode_www_form({
                                        feature_key: request_payload[:feature_key] || request_payload.feature_key,
                                        customer_key: request_payload[:customer_key] || request_payload.customer_key
                                      })

      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to check access")
    end

    def fetch_usage(base_url, api_key, request_payload)
      uri = URI.join(base_url, "usage/events")

      body = {
        customer_key: request_payload[:customer_key] || request_payload.customer_key,
        event_name: request_payload[:event_name] || request_payload.event_name,
        amount: request_payload[:amount] || request_payload.amount || 1
      }

      response = make_request(uri, "POST", api_key, body)
      parse_response(response, "Failed to record usage")
    end

    def fetch_tenant_id(base_url, api_key)
      uri = URI.join(base_url, "auth/get-tenant-id")
      response = make_request(uri, "GET", api_key)
      data = parse_response(response, "Failed to get tenant id")
      data.dig("data", "tenant_id")
    end

    def fetch_checkout_key(base_url, api_key)
      uri = URI.join(base_url, "auth/checkout-username")
      response = make_request(uri, "GET", api_key)
      data = parse_response(response, "Failed to get tenant checkout settings")
      data.dig("data", "checkout_username")
    end
  end
end

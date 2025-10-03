require "net/http"
require "uri"
require "json"
require "mime/types"
require_relative "../base_api"

module MetrifoxSDK::Usages
  class API < MetrifoxSDK::BaseApi
    def fetch_access(base_url, api_key, request_payload)
      uri = URI.join(base_url, "usage/access")

      # Handle both hash and struct access patterns
      feature_key = get_value(request_payload, :feature_key)
      customer_key = get_value(request_payload, :customer_key)

      uri.query = URI.encode_www_form({
                                        feature_key: feature_key,
                                        customer_key: customer_key
                                      })

      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to check access")
    end

    def fetch_usage(base_url, api_key, request_payload)
      uri = URI.join(base_url, "usage/events")

      # Handle both hash and struct access patterns
      customer_key = get_value(request_payload, :customer_key)
      event_name = get_value(request_payload, :event_name)
      amount = get_value(request_payload, :amount) || 1
      credit_used = get_value(request_payload, :credit_used)
      event_id = get_value(request_payload, :event_id)
      timestamp = get_value(request_payload, :timestamp)
      metadata = get_value(request_payload, :metadata) || {}

      body = {
        customer_key: customer_key,
        event_name: event_name,
        amount: amount
      }

      # Add optional fields if present
      body[:credit_used] = credit_used if credit_used
      body[:event_id] = event_id if event_id && !event_id.empty?
      body[:timestamp] = timestamp if timestamp
      body[:metadata] = metadata if metadata.present?

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

    private

    # Helper method to get value from either hash or struct
    def get_value(object, key)
      if object.respond_to?(key)
        object.public_send(key)
      elsif object.respond_to?(:[])
        object[key] || object[key.to_s]
      else
        nil
      end
    end
  end
end
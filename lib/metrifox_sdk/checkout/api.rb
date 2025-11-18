require "net/http"
require "uri"
require "json"
require_relative "../base_api"

module MetrifoxSDK::Checkout
  class API < MetrifoxSDK::BaseApi
    def fetch_checkout_key(base_url, api_key)
      uri = URI.join(base_url, "auth/checkout-username")
      response = make_request(uri, "GET", api_key)
      data = parse_response(response, "Failed to get tenant checkout settings")
      data.dig("data", "checkout_username")
    end

    def generate_checkout_url(base_url, api_key, query_params)
      uri = URI.join(base_url, "products/offerings/generate-checkout-url")
      uri.query = URI.encode_www_form(query_params)
      response = make_request(uri, "GET", api_key)
      data = parse_response(response, "Failed to generate checkout URL")
      data.dig("data", "checkout_url")
    end
  end
end
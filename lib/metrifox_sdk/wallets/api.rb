require "net/http"
require "uri"
require "json"
require_relative "../base_api"

module MetrifoxSDK::Wallets
  class API < MetrifoxSDK::BaseApi
    def list_wallets(base_url, api_key, customer_key)
      uri = URI.join(base_url, "credit_systems/v2/wallets")
      uri.query = URI.encode_www_form(customer_key: customer_key)
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to list wallets")
    end

    def list_credit_allocations(base_url, api_key, wallet_id, status: nil)
      uri = URI.join(base_url, "credit_systems/v2/wallets/#{wallet_id}/credit-allocations")
      uri.query = URI.encode_www_form(status: status) if status && !status.to_s.empty?
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to list credit allocations")
    end

    def get_credit_allocation(base_url, api_key, allocation_id)
      uri = URI.join(base_url, "credit_systems/v2/credit-allocations/#{allocation_id}")
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to get credit allocation")
    end
  end
end

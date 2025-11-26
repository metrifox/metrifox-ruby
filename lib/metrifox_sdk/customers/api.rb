require "net/http"
require "uri"
require "json"
require "mime/types"
require_relative "../base_api"

module MetrifoxSDK::Customers
  class API < MetrifoxSDK::BaseApi
    def customer_create_request(base_url, api_key, request_payload)
      uri = URI.join(base_url, "customers/new")
      body = serialize_customer_request(request_payload)
      response = make_request(uri, "POST", api_key, body)
      parse_response(response, "Failed to Create Customer")
    end

    def customer_update_request(base_url, api_key, customer_key, request_payload)
      uri = URI.join(base_url, "customers/#{customer_key}")
      body = serialize_customer_request(request_payload)
      response = make_request(uri, "PATCH", api_key, body)
      parse_response(response, "Failed to UPDATE Customer")
    end

    def customer_delete_request(base_url, api_key, request_payload)
      customer_key = get_value(request_payload, :customer_key)
      uri = URI.join(base_url, "customers/#{customer_key}")
      response = make_request(uri, "DELETE", api_key)
      parse_response(response, "Failed to DELETE Customer")
    end

    def customer_get_request(base_url, api_key, request_payload)
      customer_key = get_value(request_payload, :customer_key)
      uri = URI.join(base_url, "customers/#{customer_key}")
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to Fetch Customer")
    end

    def customer_details_get_request(base_url, api_key, request_payload)
      customer_key = get_value(request_payload, :customer_key)
      uri = URI.join(base_url, "customers/#{customer_key}/details")
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to Fetch Customer Details")
    end

    def customer_active_subscription_request(base_url, api_key, customer_key)
      uri = URI.join(base_url, "customers/#{customer_key}/check-active-subscription")
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to Check Active Subscription")
    end

    def customer_list_request(base_url, api_key, request_payload = {})
      uri = URI.join(base_url, "customers")
      
      # Build query parameters from the request payload
      query_params = build_query_params(request_payload)
      if query_params && !query_params.empty?
        uri.query = URI.encode_www_form(query_params)
      end
      
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to Fetch Customers")
    end

    def upload_customers_csv(base_url, api_key, file_path)
      uri = URI.join(base_url, "customers/csv-upload")

      boundary = "----WebKitFormBoundary#{Random.hex(16)}"
      body = build_multipart_body(file_path, boundary)

      headers = {
        "x-api-key" => api_key,
        "Content-Type" => "multipart/form-data; boundary=#{boundary}"
      }

      response = make_raw_request(uri, "POST", headers, body)
      parse_response(response, "Failed to upload CSV")
    end

    private

    def serialize_customer_request(request)
      if request.respond_to?(:to_h)
        request.to_h.compact
      elsif request.is_a?(Hash)
        request.compact
      else
        raise ArgumentError, "Invalid request format"
      end
    end

    # Helper method to build query parameters for list requests
    def build_query_params(request_payload)
      return {} unless request_payload

      params = {}
      
      # Handle pagination parameters
      params[:page] = get_value(request_payload, :page) if get_value(request_payload, :page)
      params[:per_page] = get_value(request_payload, :per_page) if get_value(request_payload, :per_page)
      
      # Handle filter parameters
      params[:search_term] = get_value(request_payload, :search_term) if get_value(request_payload, :search_term)
      params[:customer_type] = get_value(request_payload, :customer_type) if get_value(request_payload, :customer_type)
      params[:date_created] = get_value(request_payload, :date_created) if get_value(request_payload, :date_created)
      
      params.compact
    end

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

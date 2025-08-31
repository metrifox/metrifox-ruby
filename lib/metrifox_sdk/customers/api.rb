require "net/http"
require "uri"
require "json"
require "mime/types"
require_relative "../base_api"

module MetrifoxSdk::Customers
  class API < MetrifoxSdk::BaseApi
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
      customer_key = request_payload[:customer_key] || request_payload.customer_key
      uri = URI.join(base_url, "customers/#{customer_key}")
      response = make_request(uri, "DELETE", api_key)
      parse_response(response, "Failed to DELETE Customer")
    end

    def customer_get_request(base_url, api_key, request_payload)
      customer_key = request_payload[:customer_key] || request_payload.customer_key
      uri = URI.join(base_url, "customers/#{customer_key}")
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to Fetch Customer")
    end

    def customer_details_get_request(base_url, api_key, request_payload)
      customer_key = request_payload[:customer_key] || request_payload.customer_key
      uri = URI.join(base_url, "customers/#{customer_key}/details")
      response = make_request(uri, "GET", api_key)
      parse_response(response, "Failed to Fetch Customer Details")
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
  end
end

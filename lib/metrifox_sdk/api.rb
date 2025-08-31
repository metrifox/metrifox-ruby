require "net/http"
require "uri"
require "json"
require "mime/types"

module MetrifoxSdk
  class APIError < StandardError; end
  class API
    class << self
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

      def make_request(uri, method, api_key, body = nil)
        headers = {
          "x-api-key" => api_key,
          "Content-Type" => "application/json"
        }

        body_json = body ? JSON.generate(body) : nil
        make_raw_request(uri, method, headers, body_json)
      end

      def make_raw_request(uri, method, headers, body = nil)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"

        request = case method
                  when "GET"
                    Net::HTTP::Get.new(uri)
                  when "POST"
                    Net::HTTP::Post.new(uri)
                  when "PATCH"
                    Net::HTTP::Patch.new(uri)
                  when "DELETE"
                    Net::HTTP::Delete.new(uri)
                  else
                    raise ArgumentError, "Unsupported HTTP method: #{method}"
                  end

        headers.each { |key, value| request[key] = value }
        request.body = body if body

        http.request(request)
      end

      def parse_response(response, error_message)
        unless response.is_a?(Net::HTTPSuccess)
          raise APIError, "#{error_message}: #{response.code} #{response.message}"
        end

        JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise APIError, "Invalid JSON response: #{e.message}"
      end

      def serialize_customer_request(request)
        if request.respond_to?(:to_h)
          request.to_h.compact
        elsif request.is_a?(Hash)
          request.compact
        else
          raise ArgumentError, "Invalid request format"
        end
      end

      def build_multipart_body(file_path, boundary)
        unless File.exist?(file_path)
          raise ArgumentError, "File not found: #{file_path}"
        end

        file_content = File.read(file_path)
        filename = File.basename(file_path)
        mime_type = MIME::Types.type_for(filename).first&.content_type || "text/csv"

        body = []
        body << "--#{boundary}"
        body << 'Content-Disposition: form-data; name="csv"; filename="' + filename + '"'
        body << "Content-Type: #{mime_type}"
        body << ""
        body << file_content
        body << "--#{boundary}--"
        body << ""

        body.join("\r\n")
      end
    end
  end
end

require "net/http"
require "uri"
require "json"
require "mime/types"

module MetrifoxSdk
  class BaseApi
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

  class APIError < StandardError; end
end

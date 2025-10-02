require_relative "api"
require_relative "../base_module"

module MetrifoxSDK
  module Checkout
    class Module < BaseModule
      def url(config)
        validate_api_key!
        
        # Handle both hash and struct access patterns
        offering_key = get_value(config, :offering_key)
        billing_interval = get_value(config, :billing_interval)
        customer_key = get_value(config, :customer_key)

        raise ArgumentError, "offering_key is required" if offering_key.nil? || offering_key.empty?

        checkout_key = get_checkout_key
        raise StandardError, "Checkout Key could not be retrieved. Ensure the API key is valid" if checkout_key.nil? || checkout_key.empty?

        url_string = "#{web_app_base_url}/#{checkout_key}/checkout/#{offering_key}"
        uri = URI(url_string)
        
        # Add query parameters if provided
        query_params = {}
        query_params["billing_period"] = billing_interval if billing_interval && !billing_interval.empty?
        query_params["customer"] = customer_key if customer_key && !customer_key.empty?
        
        uri.query = URI.encode_www_form(query_params) unless query_params.empty?
        
        uri.to_s
      end

      private

      def get_checkout_key
        api.fetch_checkout_key(base_url, api_key)
      end

      def web_app_base_url
        @client.web_app_base_url
      end

      def api
        @api ||= API.new
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
end
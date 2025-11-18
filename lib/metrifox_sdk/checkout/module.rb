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

        # Build query parameters
        query_params = { offering_key: offering_key }
        query_params[:billing_interval] = billing_interval if billing_interval && !billing_interval.empty?
        query_params[:customer_key] = customer_key if customer_key && !customer_key.empty?

        # Call API to generate checkout URL
        checkout_url = api.generate_checkout_url(base_url, api_key, query_params)
        raise StandardError, "Checkout URL could not be generated" if checkout_url.nil? || checkout_url.empty?

        checkout_url
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
require_relative "api"
require_relative "../base_module"

module MetrifoxSDK
  module Wallets
    class Module < BaseModule
      def list(customer_key)
        validate_api_key!
        api.list_wallets(base_url, api_key, customer_key)
      end

      def list_credit_allocations(wallet_id, status: nil)
        validate_api_key!
        api.list_credit_allocations(base_url, api_key, wallet_id, status: status)
      end

      def get_credit_allocation(allocation_id)
        validate_api_key!
        api.get_credit_allocation(base_url, api_key, allocation_id)
      end

      private

      def api
        @api ||= API.new
      end
    end
  end
end

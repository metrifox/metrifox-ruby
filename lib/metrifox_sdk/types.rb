module MetrifoxSDK
  module Types
    UsageEventRequest = Struct.new(
      :customer_key, :event_name, :feature_key, :amount, :credit_used, :event_id, :timestamp, :metadata,
      keyword_init: true
    ) do
      def initialize(customer_key:, event_name: nil, feature_key: nil, amount: 1, credit_used: nil, event_id: nil, timestamp: nil, metadata: {})
        super
      end
    end

    CheckoutConfig = Struct.new(:offering_key, :billing_interval, :customer_key, keyword_init: true)
  end
end

require_relative "metrifox_sdk/version"
require_relative "metrifox_sdk/client"
require_relative "metrifox_sdk/types"
require_relative "metrifox_sdk/api"
require_relative "metrifox_sdk/util"

module MetrifoxSDK
  class << self
    include MetrifoxSdk::UtilMethods

    attr_accessor :client

    def init(config = {})
      @client = MetrifoxSdk::Client.new(config)
      @client
    end

    def check_access(request_payload)
      client.check_access(request_payload)
    end

    def record_usage(request_payload)
      client.record_usage(request_payload)
    end

    def create_customer(request_payload)
      client.create_customer(request_payload)
    end

    def update_customer(customer_key, request_payload)
      client.update_customer(customer_key, request_payload)
    end

    def get_customer(request_payload)
      client.get_customer(request_payload)
    end

    def get_customer_details(request_payload)
      client.get_customer_details(request_payload)
    end

    def delete_customer(request_payload)
      client.delete_customer(request_payload)
    end

    def upload_customers_csv(file_path)
      client.upload_customers_csv(file_path)
    end

    private

    def client
      @client ||= begin
                    load_dotenv
                    Client.new
                  end
    end
  end
end
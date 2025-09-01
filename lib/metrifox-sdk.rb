require_relative "metrifox_sdk/version"
require_relative "metrifox_sdk/client"
require_relative "metrifox_sdk/types"
require_relative "metrifox_sdk/util_methods"
require_relative "metrifox_sdk/base_api"
require_relative "metrifox_sdk/base_module"
require_relative "metrifox_sdk/customers/module"
require_relative "metrifox_sdk/usages/module"

module MetrifoxSDK
  class << self
    def init(config = {})
      Client.new(config)
    end
  end
end
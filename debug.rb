require "metrifox-sdk"

metrifox = MetrifoxSDK.init(
  {
    api_key: "eb95ce038b6ba42a02b2ff254b37b3e7eadd1564e7fe566f1ac7a563de62ca12",
    base_url: "http://localhost:3003/api/v1/"
  })

customer_details = metrifox.customers.get_details({ customer_key: "ACME_CORP_001" })

puts customer_details


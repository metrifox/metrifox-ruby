require_relative '../lib/metrifox_sdk/customers/module'
require 'spec_helper'
require 'webmock/rspec'
require 'tempfile'

RSpec.describe MetrifoxSDK::Customers::Module do
  let(:api_key) { "test-api-key" }
  let(:base_url) { "https://api.example.com/api/v1/" }
  let(:client) do
    MetrifoxSDK::Client.new(
      api_key: api_key,
      base_url: base_url
    )
  end
  let(:customers_module) { client.customers }
  let(:customer_key) { "okoro_manufacturing_2024_006" }
  let(:customer_payload) do
    {
      customer_type: "BUSINESS",
      customer_key: customer_key,
      primary_email: "support@okoromanufacturing2.com.ng",
      primary_phone: "+2348012345678",
      legal_name: "Okoro Manufacturing Limited",
      display_name: "Okoro Manufacturing",
      legal_number: "RC1234567890",
      tax_identification_number: "TIN567890123",
      logo_url: "https://okoromanufacturing.com/logo.png",
      website_url: "https://okoromanufacturing.com",
      account_manager: "Emmanuel Okoro",
      billing_email: "billing@okoromanufacturing.com",
      timezone: "Africa/Lagos",
      language: "en",
      currency: "NGN",
      tax_status: "TAXABLE",
      address_line1: "Plot 15, Industrial Layout",
      address_line2: "Garki District",
      city: "Abuja",
      state: "FCT",
      country: "Nigeria",
      zip_code: "900001",
      shipping_address_line1: "Warehouse 3B, Ikeja Industrial Estate",
      shipping_address_line2: "Ogba Road",
      shipping_city: "Lagos",
      shipping_state: "Lagos",
      shipping_country: "Nigeria",
      shipping_zip_code: "100218",
      billing_configuration: {
        preferred_payment_gateway: "stripe",
        preferred_payment_method: "card",
        billing_email: "billing@okoromanufacturing.com",
        billing_address: "Plot 15, Industrial Layout, Garki District, Abuja, FCT, Nigeria, 900001",
        payment_reminder_days: nil
      },
      tax_identifications: [
        {
          type: "VAT",
          number: "VAT123456789",
          country: "Nigeria"
        }
      ],
      contact_people: [
        {
          first_name: "Chika",
          last_name: "Okoro",
          email_address: "chika@okoromanufacturing.com",
          designation: "Finance Manager",
          department: "Finance",
          is_primary: true,
          phone_number: "+2348087654321"
        }
      ],
      payment_terms: [
        {
          type: "Custom",
          value: "7"
        }
      ],
      metadata: {
        source: "website_registration",
        referral_code: "REF2024001",
        industry: "Manufacturing"
      },
      email_addresses: [
        {
          email: "info@okoromanufacturing.com.ng",
          is_primary: true
        }
      ],
      phone_numbers: [
        {
          phone_number: "8012345678",
          country_code: "+234",
          is_primary: true
        }
      ]
    }
  end

  before do
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  describe "#create" do
    let(:expected_response) do
      {
        "statusCode" => 201,
        "message" => "Customer Created Successfully",
        "meta" => {},
        "data" => {
          "id" => "8cd3bde1-96ca-4f01-b015-aad9ce861e91",
          "primary_email" => "support@okoromanufacturing2.com.ng",
          "primary_phone" => "+2348012345678",
          "legal_name" => "Okoro Manufacturing Limited",
          "customer_key" => customer_key,
          "created_at" => "2025-08-30T19:58:31.007Z",
          "updated_at" => "2025-08-30T19:58:31.007Z"
        },
        "errors" => {}
      }
    end

    it "creates a customer successfully" do
      stub_request(:post, "#{base_url}customers/new")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          },
          body: customer_payload.to_json
        )
        .to_return(
          status: 201,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.create(customer_payload)
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(201)
      expect(result["message"]).to eq("Customer Created Successfully")
      expect(result["data"]["customer_key"]).to eq(customer_key)
    end

    it "handles API errors gracefully" do
      error_response = {
        "statusCode" => 400,
        "message" => "Bad Request - Invalid customer data",
        "meta" => {},
        "data" => nil,
        "errors" => {
          "primary_email" => ["is required"],
          "customer_key" => ["must be unique"]
        }
      }

      stub_request(:post, "#{base_url}customers/new")
        .to_return(
          status: 400,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { customers_module.create(customer_payload) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to Create Customer: 400/)
    end

    it "validates API key is not empty string" do
      client_with_empty_key = MetrifoxSDK::Client.new(api_key: "")
      customers_module_empty_key = client_with_empty_key.customers

      expect { customers_module_empty_key.create(customer_payload) }
        .to raise_error(MetrifoxSDK::ConfigurationError, /API key required/)
    end
  end

  describe "#get" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Customer Retrieved Successfully",
        "meta" => {},
        "data" => {
          "id" => "8cd3bde1-96ca-4f01-b015-aad9ce861e91",
          "customer_key" => customer_key,
          "primary_email" => "support@okoromanufacturing2.com.ng",
          "customer_type" => "BUSINESS",
          "legal_name" => "Okoro Manufacturing Limited",
          "display_name" => "Okoro Manufacturing"
        },
        "errors" => {}
      }
    end

    it "fetches a customer successfully" do
      stub_request(:get, "#{base_url}customers/#{customer_key}")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.get({ customer_key: customer_key })
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(200)
      expect(result["data"]["customer_key"]).to eq(customer_key)
    end

    it "handles customer not found" do
      error_response = {
        "statusCode" => 404,
        "message" => "Customer not found",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:get, "#{base_url}customers/#{customer_key}")
        .to_return(
          status: 404,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { customers_module.get({ customer_key: customer_key }) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to Fetch Customer: 404/)
    end
  end

  describe "#get_details" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Customer Details Retrieved Successfully",
        "meta" => {},
        "data" => {
          "metrifox_id" => "8cd3bde1-96ca-4f01-b015-aad9ce861e91",
          "customer_key" => customer_key,
          "subscriptions" => [],
          "entitlements" => [],
          "wallets" => []
        },
        "errors" => {}
      }
    end

    it "fetches customer details successfully" do
      stub_request(:get, "#{base_url}customers/#{customer_key}/details")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.get_details({ customer_key: customer_key })
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(200)
      expect(result["data"]["customer_key"]).to eq(customer_key)
      expect(result["data"]["subscriptions"]).to eq([])
      expect(result["data"]["entitlements"]).to eq([])
      expect(result["data"]["wallets"]).to eq([])
    end

    it "handles customer not found" do
      error_response = {
        "statusCode" => 404,
        "message" => "Customer not found",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:get, "#{base_url}customers/#{customer_key}/details")
        .to_return(
          status: 404,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { customers_module.get_details({ customer_key: customer_key }) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to Fetch Customer Details: 404/)
    end
  end

  describe "#has_active_subscription?" do
    it "returns true when customer has an active subscription" do
      stub_request(:get, "#{base_url}customers/#{customer_key}/check-active-subscription")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: { has_active_subscription: true }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.has_active_subscription?(customer_key: customer_key)
      expect(result['has_active_subscription']).to be true
    end

    it "handles 404 errors from the API" do
      stub_request(:get, "#{base_url}customers/#{customer_key}/check-active-subscription")
        .to_return(
          status: 404,
          body: { message: "Not found" }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { customers_module.has_active_subscription?(customer_key: customer_key) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to Check Active Subscription: 404/)
    end
  end

  describe "#update" do
    let(:update_payload) do
      {
        primary_email: "updated@okoromanufacturing.com",
        legal_name: "Updated Okoro Manufacturing Limited"
      }
    end

    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Customer Updated Successfully",
        "meta" => {},
        "data" => {
          "id" => "8cd3bde1-96ca-4f01-b015-aad9ce861e91",
          "customer_key" => customer_key,
          "primary_email" => "updated@okoromanufacturing.com",
          "legal_name" => "Updated Okoro Manufacturing Limited",
          "updated_at" => "2025-08-30T20:15:45.123Z"
        },
        "errors" => {}
      }
    end

    it "updates a customer successfully" do
      stub_request(:patch, "#{base_url}customers/#{customer_key}")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          },
          body: update_payload.to_json
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.update(customer_key, update_payload)
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(200)
      expect(result["data"]["primary_email"]).to eq("updated@okoromanufacturing.com")
    end

    it "handles update errors" do
      error_response = {
        "statusCode" => 422,
        "message" => "Validation Error",
        "meta" => {},
        "data" => nil,
        "errors" => {
          "primary_email" => ["is not a valid email format"]
        }
      }

      stub_request(:patch, "#{base_url}customers/#{customer_key}")
        .to_return(
          status: 422,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { customers_module.update(customer_key, update_payload) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to UPDATE Customer: 422/)
    end
  end

  describe "#delete" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Customer Deleted Successfully",
        "meta" => {},
        "data" => {
          "deleted" => true,
          "customer_key" => customer_key
        },
        "errors" => {}
      }
    end

    it "deletes a customer successfully" do
      stub_request(:delete, "#{base_url}customers/#{customer_key}")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.delete({ customer_key: customer_key })
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(200)
      expect(result["data"]["deleted"]).to be true
    end

    it "handles delete errors" do
      error_response = {
        "statusCode" => 404,
        "message" => "Customer not found",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:delete, "#{base_url}customers/#{customer_key}")
        .to_return(
          status: 404,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { customers_module.delete({ customer_key: customer_key }) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to DELETE Customer: 404/)
    end
  end

  describe "#upload_csv" do
    let(:csv_content) do
      "customer_key,customer_type,primary_email,display_name\n" \
        "ACME_CORP_001,BUSINESS,contact@acmecorp.com,Acme Corp\n" \
        "TECHSTART_002,BUSINESS,info@techstart.io,TechStart\n" \
        "JOHN_SMITH_006,INDIVIDUAL,john.smith@email.com,John Smith\n"
    end

    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Customers Upload Completed",
        "meta" => {},
        "data" => {
          "total_customers" => 3,
          "successful_upload_count" => 3,
          "failed_upload_count" => 0,
          "customers_added" => [
            {
              "row" => 1,
              "customer_key" => "ACME_CORP_001",
              "data" => {
                "customer_type" => "BUSINESS",
                "email" => "contact@acmecorp.com",
                "display_name" => "Acme Corp"
              }
            },
            {
              "row" => 2,
              "customer_key" => "TECHSTART_002",
              "data" => {
                "customer_type" => "BUSINESS",
                "email" => "info@techstart.io",
                "display_name" => "TechStart"
              }
            },
            {
              "row" => 3,
              "customer_key" => "JOHN_SMITH_006",
              "data" => {
                "customer_type" => "INDIVIDUAL",
                "email" => "john.smith@email.com",
                "display_name" => "John Smith"
              }
            }
          ],
          "customers_failed" => []
        },
        "errors" => {}
      }
    end

    it "uploads CSV file successfully" do
      temp_file = Tempfile.new(['customers', '.csv'])
      temp_file.write(csv_content)
      temp_file.rewind
      temp_file.close

      stub_request(:post, "#{base_url}customers/csv-upload")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => /multipart\/form-data/
          }
        ) do |request|
        expect(request.body).to include(csv_content)
        expect(request.body).to include('Content-Disposition: form-data; name="csv"')
        expect(request.body).to include('Content-Type: text/csv')
      end
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.upload_csv(temp_file.path)
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(200)
      expect(result["data"]["total_customers"]).to eq(3)
      expect(result["data"]["successful_upload_count"]).to eq(3)

      temp_file.unlink
    end

    it "handles file not found error" do
      non_existent_file = "./non_existent_file.csv"

      expect { customers_module.upload_csv(non_existent_file) }
        .to raise_error(ArgumentError, /File not found/)
    end

    it "handles CSV upload API errors" do
      temp_file = Tempfile.new(['customers', '.csv'])
      temp_file.write(csv_content)
      temp_file.rewind
      temp_file.close

      error_response = {
        "statusCode" => 413,
        "message" => "File too large",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:post, "#{base_url}customers/csv-upload")
        .to_return(
          status: 413,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { customers_module.upload_csv(temp_file.path) }
        .to raise_error(MetrifoxSDK::APIError, /Failed to upload CSV: 413/)

      temp_file.unlink
    end
  end

  describe "#list" do
    let(:expected_response) do
      {
        "statusCode" => 200,
        "message" => "Customers Fetched",
        "meta" => {
          "current_page" => 1,
          "total_pages" => 1,
          "total_count" => 2,
          "limit_value" => 25,
          "next_page" => nil,
          "prev_page" => nil,
          "first_page?" => true,
          "last_page?" => true,
          "out_of_range?" => false
        },
        "data" => [
          {
            "id" => "341d4d46-9abe-4710-95b5-a09919c0a359",
            "primary_email" => "info@techstart.io",
            "primary_phone" => "+1-555-0202",
            "legal_name" => "TechStart Solutions LLC",
            "display_name" => "TechStart",
            "customer_type" => "BUSINESS",
            "customer_key" => "TECHSTART_002"
          },
          {
            "id" => "1326e1f3-64c9-4340-a61b-e0a65bad9478",
            "primary_email" => "john.smith@email.com",
            "primary_phone" => "+1-555-1234",
            "display_name" => "John Smith",
            "customer_type" => "INDIVIDUAL",
            "customer_key" => "JOHN_SMITH_006"
          }
        ],
        "errors" => {}
      }
    end

    it "fetches customers list successfully" do
      stub_request(:get, "#{base_url}customers")
        .with(
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.list
      expect(result).to eq(expected_response)
      expect(result["statusCode"]).to eq(200)
      expect(result["message"]).to eq("Customers Fetched")
      expect(result["data"]).to be_an(Array)
      expect(result["data"].length).to eq(2)
    end

    it "fetches customers with pagination parameters" do
      list_params = { page: 2, per_page: 10 }
      
      stub_request(:get, "#{base_url}customers")
        .with(
          query: { page: "2", per_page: "10" },
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.list(list_params)
      expect(result).to eq(expected_response)
    end

    it "fetches customers with filter parameters" do
      list_params = { 
        search_term: "TechStart",
        customer_type: "BUSINESS",
        date_created: "2025-09-01"
      }
      
      stub_request(:get, "#{base_url}customers")
        .with(
          query: { 
            search_term: "TechStart",
            customer_type: "BUSINESS",
            date_created: "2025-09-01"
          },
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.list(list_params)
      expect(result).to eq(expected_response)
    end

    it "fetches customers with combined pagination and filter parameters" do
      list_params = { 
        page: 1,
        per_page: 5,
        search_term: "John",
        customer_type: "INDIVIDUAL"
      }
      
      stub_request(:get, "#{base_url}customers")
        .with(
          query: { 
            page: "1",
            per_page: "5",
            search_term: "John",
            customer_type: "INDIVIDUAL"
          },
          headers: {
            'x-api-key' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = customers_module.list(list_params)
      expect(result).to eq(expected_response)
    end

    it "handles list API errors" do
      error_response = {
        "statusCode" => 500,
        "message" => "Internal Server Error",
        "meta" => {},
        "data" => nil,
        "errors" => {}
      }

      stub_request(:get, "#{base_url}customers")
        .to_return(
          status: 500,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { customers_module.list }
        .to raise_error(MetrifoxSDK::APIError, /Failed to Fetch Customers: 500/)
    end
  end
end

module MetrifoxSdk
  module Types
    # Enums
    module TaxStatus
      TAXABLE = "TAXABLE"
      TAX_EXEMPT = "TAX_EXEMPT"
      REVERSE_CHARGE = "REVERSE_CHARGE"
    end

    module CustomerType
      BUSINESS = "BUSINESS"
      INDIVIDUAL = "INDIVIDUAL"
    end

    # Value objects / Structs
    EmailAddress = Struct.new(:email, :is_primary, keyword_init: true)
    PhoneNumber = Struct.new(:phone_number, :country_code, :is_primary, keyword_init: true)

    Address = Struct.new(
      :country, :address_line_one, :address_line_two, :city,
      :state, :zip_code, :phone_number, keyword_init: true
    )

    BillingConfig = Struct.new(
      :preferred_payment_gateway, :preferred_payment_method, :billing_email,
      :billing_address, :payment_reminder_days, keyword_init: true
    )

    TaxIdentification = Struct.new(:type, :number, :country, keyword_init: true)

    ContactPerson = Struct.new(
      :first_name, :last_name, :email_address, :designation,
      :department, :is_primary, :phone_number, keyword_init: true
    )

    PaymentTerm = Struct.new(:type, :value, keyword_init: true)

    # Request/Response objects
    AccessCheckRequest = Struct.new(:feature_key, :customer_key, keyword_init: true)

    AccessResponse = Struct.new(
      :message, :can_access, :customer_id, :feature_key, :required_quantity,
      :used_quantity, :included_usage, :next_reset_at, :quota, :unlimited,
      :carryover_quantity, :balance, keyword_init: true
    )

    UsageEventRequest = Struct.new(:customer_key, :event_name, :amount, keyword_init: true) do
      def initialize(customer_key:, event_name:, amount: 1)
        super
      end
    end

    UsageEventResponse = Struct.new(:message, :event_name, :customer_key, keyword_init: true)

    CustomerCreateRequest = Struct.new(
      # Core fields
      :customer_key, :customer_type, :primary_email, :primary_phone,
      # Business fields
      :legal_name, :display_name, :legal_number, :tax_identification_number,
      :logo_url, :website_url, :account_manager,
      # Individual fields
      :first_name, :middle_name, :last_name, :date_of_birth, :billing_email,
      # Preferences
      :timezone, :language, :currency, :tax_status,
      # Address fields
      :address_line1, :address_line2, :city, :state, :country, :zip_code,
      # Shipping address fields
      :shipping_address_line1, :shipping_address_line2, :shipping_city,
      :shipping_state, :shipping_country, :shipping_zip_code,
      # Complex fields
      :billing_configuration, :tax_identifications, :contact_people,
      :payment_terms, :metadata, keyword_init: true
    )

    CustomerUpdateRequest = Struct.new(
      # Core fields
      :customer_key, :customer_type, :primary_email, :primary_phone, :billing_email,
      # Business fields
      :legal_name, :display_name, :legal_number, :tax_identification_number,
      :logo_url, :website_url, :account_manager,
      # Individual fields
      :first_name, :middle_name, :last_name, :date_of_birth,
      # Preferences
      :timezone, :language, :currency, :tax_status,
      # Address fields
      :address_line1, :address_line2, :city, :state, :country, :zip_code,
      # Shipping address fields
      :shipping_address_line1, :shipping_address_line2, :shipping_city,
      :shipping_state, :shipping_country, :shipping_zip_code,
      # Complex fields
      :billing_configuration, :tax_identifications, :contact_people,
      :payment_terms, :metadata, :phone_numbers, :email_addresses, keyword_init: true
    )

    CustomerDeleteRequest = Struct.new(:customer_key, keyword_init: true)
    CustomerGetRequest = Struct.new(:customer_key, keyword_init: true)

    CustomerCSVSyncResponse = Struct.new(
      :status_code, :message, :data, :errors, :meta, keyword_init: true
    ) do
      CSVSyncData = Struct.new(
        :total_customers, :successful_upload_count, :failed_upload_count,
        :customers_added, :customers_failed, keyword_init: true
      )
    end

    APIResponse = Struct.new(:status_code, :message, :data, :errors, :meta, keyword_init: true)

    EmbedConfig = Struct.new(:container, :product_key, keyword_init: true)
  end
end
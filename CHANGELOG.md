# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [1.3.0]
- Add `wallets` module with `list`, `list_credit_allocations`, and `get_credit_allocation` methods.
- Add `customers.archive` and `customers.unarchive`.
- Add `checkout.card_collection_url(subscription_id:, order_id:)` for generating card-collection URLs.
- Add `usages.list_events` for listing recorded usage events with optional filters and pagination.
- Add `usages.quantity_price(customer_key:, feature_key:, quantity:)` for computing the price of a usage quantity.
- Allow overriding the meter service base URL via `meter_service_base_url` config or `METRIFOX_METER_SERVICE_BASE_URL` env var.

## [1.2.x]
- Update usage access and recording to call the meter service (`https://api-meter.metrifox.com`).

## [1.0.3] - 2025-09-01
- Initial release
- Access control functionality
- Usage tracking
- Customer management
- CSV upload support

require 'dry-schema'
require "dry-validation"

HomeDetailsSchema = Dry::Schema.JSON do
  required(:name).filled(:string)
  required(:abbrev).filled(:string)
  required(:country_id).filled(:integer)
  required(:region_id).filled(:integer)
  required(:city_id).filled(:integer)
  required(:neighborhood_id).filled(:integer)
  required(:real_estate_partner_id).filled(:integer)
  optional(:description).filled(:string)
end

DestinationAccountSchema = Dry::Schema.JSON do
  required(:name).filled(:string)
  required(:account_number).filled(:string)
  required(:description).filled(:string)
end

DestinationAccountsSchema = Dry::Schema.JSON do
  required(:home_details).hash(HomeDetailsSchema)
  required(:destination_accounts).array(DestinationAccountSchema).value(min_size?: 0)
end

BuildingDetailSchema = Dry::Schema.JSON do
  required(:name).filled(:string)
  required(:address).filled(:string)
  required(:description).filled(:string)
  required(:housing_type_id).filled(:integer)
end

BuildingDetailsSchema = Dry::Schema.JSON do
  required(:home_details).hash(HomeDetailsSchema)
  optional(:destination_accounts).array(:hash) do
    required(:destination_account).hash(DestinationAccountSchema)
  end
  required(:building_details).array(BuildingDetailSchema).value(min_size?: 1)
end

class HomeDetailsContract < Dry::Validation::Contract
  @__schema__ = HomeDetailsSchema

  option :validator

  rule(:country_id) do
    key.failure("invalid country") unless validator.valid?(values[:country_id])
  end
  rule(:city_id) do
    key.failure("invalid city") unless validator.valid?(values[:city_id])
  end
  rule(:region_id) do
    key.failure("invalid region") unless validator.valid?(values[:region_id])
  end
  rule(:neighborhood_id) do
    key.failure("invalid neighborhood") unless validator.valid?(values[:neighborhood_id])
  end
end

class Validator
  def valid?(id)
    # this will really be something like City.find(id).present?
    id <= 100 # to deterministically test it
  end
end


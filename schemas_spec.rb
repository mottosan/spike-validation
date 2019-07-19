require_relative "./schemas"

describe "Schemas" do
  describe HomeDetailsSchema do
    let(:good) do
      {
        name: "this is the foo building",
        abbrev: "foo",
        country_id: 1,
        region_id: 2,
        city_id: 3,
        neighborhood_id: 4,
        real_estate_partner_id: 5
      }
    end
    let(:good_with_desc) { good.merge({ description: "this is a description" }) }
    let(:bad1) do
      {
        name: "this is the foo building",
        abbrev: "foo",
      }
    end
    let(:bad2) do
      {
        name: "this is the foo building",
        abbrev: "foo",
        country_id: "sdfasd",
      }
    end
    let(:schema) { HomeDetailsSchema }

    context "valid json" do
      it "validates correctly without optional field" do
        expect(schema.call(good).errors).to be_empty
      end

      it "valididates with optional field" do
        expect(schema.call(good_with_desc).errors).to be_empty
      end
    end

    context "invalid json" do
      context "missing required fields" do
        it "returns an error" do
          errors = schema.call(bad1).errors.to_h
          expect(errors).not_to be_empty
          expect(errors).to include(:country_id, :region_id, :city_id, :neighborhood_id)
        end
      end

      context "invalid type for country id" do
        it "returns an error" do
          errors = schema.call(bad2).errors.to_h
          expect(errors).not_to be_empty
          expect(errors).to include(:country_id, :region_id, :city_id, :neighborhood_id)
          expect(errors[:country_id]).to include "must be an integer"
          expect(errors[:city_id]).to include "is missing"
          expect(errors[:region_id]).to include "is missing"
          expect(errors[:neighborhood_id]).to include "is missing"
        end
      end
    end
  end

  describe "DestinationAccountsSchema" do
    let(:home_details) do
      {
        name: "this is the foo building",
        abbrev: "foo",
        country_id: 1,
        region_id: 2,
        city_id: 3,
        neighborhood_id: 4,
        real_estate_partner_id: 5
      }
    end

    let(:home) do
      { home_details: home_details, destination_accounts: [] }
    end

    let(:destination_acc) {{ name: "bleh", account_number: "1234456", description: "checking account" }}

    let(:schema) { DestinationAccountsSchema }

    context "no destination accounts" do
      it "returns no error" do
        errors = schema.call(home).errors.to_h
        expect(errors).to be_empty
      end
    end

    context "with missing top level destination account key" do
      let(:bad) do
        { home_details: home_details }
      end
      it "returns no error" do
        errors = schema.call(bad).errors.to_h
        expect(errors).not_to be_empty
        expect(errors).to include(:destination_accounts)
        expect(errors[:destination_accounts]).to include "is missing"
      end
    end

    context "with a valid destination account set" do
      let(:good) do
        home.merge({ destination_accounts: [ destination_acc ] })
      end
      it "returns no error" do
        expect(schema.call(good).errors.to_h).to be_empty
      end
    end

    context "with multiple destination accounts" do
      let(:good) do
        home.merge({ destination_accounts: [ destination_acc, destination_acc ] })
      end
      it "returns no error" do
        expect(schema.call(good).errors.to_h).to be_empty
      end
    end
  end

  describe "BuildingDetailsSchema" do
    let(:schema) { BuildingDetailsSchema }
    let(:home_details) do
      {
        name: "this is the foo building",
        abbrev: "foo",
        country_id: 1,
        region_id: 2,
        city_id: 3,
        neighborhood_id: 4,
        real_estate_partner_id: 5
      }
    end
    let(:home) do
      { home_details: home_details, destination_accounts: [] }
    end

    context "with no building_details key set " do
      it "returns an error" do
        errors = schema.call(home).errors.to_h
        expect(errors[:building_details]).to include "is missing"
      end
    end

    context "with a building_details key set" do
      let(:bad) do
        home.merge({
          building_details: []
        })
      end
      it "returns an error" do
        errors = schema.call(home).errors.to_h
        expect(errors[:building_details]).to include "is missing"
      end

      context "with a building_detail passed in" do
        let(:good) do
          home.merge(
            building_details: [{
            name: "baltic",
            address: "foo bar street, new york, NY 10001",
            description: "this is baltic",
            housing_type_id: 123,
            }]
          )
        end

        it "validates correctly" do
          errors = schema.call(good).errors.to_h
          expect(errors).to be_empty
        end
      end
    end

    context "with building missing details" do
      it "returns an error" do

      end
    end
  end

  describe HomeDetailsContract do
    let(:validator) { Validator.new }
    let(:contract) { described_class.new(
      validator: validator
    )}

    context "valid associations" do
      let(:payload) do
        {
          name: "this is the foo building",
          abbrev: "foo",
          country_id: 1,
          region_id: 2,
          city_id: 3,
          neighborhood_id: 4,
          real_estate_partner_id: 5
        }
      end
      it "returns no errors" do
        expect(contract.call(payload).errors.to_h).to be_empty
      end
    end
    context "invalid associations" do
      let(:payload) do
        {
          name: "this is the foo building",
          abbrev: "foo",
          country_id: 1,
          region_id: 2,
          city_id: 300,
          neighborhood_id: 4,
          real_estate_partner_id: 5
        }
      end
      it "returns no errors" do
        errors = contract.call(payload).errors.to_h
        expect(errors).not_to be_empty
        expect(errors[:city_id]).to include "invalid city"
      end
    end
  end
end

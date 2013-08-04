require 'spec_helper'
require 'base64'

describe "Inapp Purchase Api" do
  describe "when I do a GET on /in_app_purchase/products" do
    it "should return a list of product identifiers" do
      prod_one = FactoryGirl.create(:inapp_product)
      prod_two = FactoryGirl.create(:inapp_product)

      get "/in_app_purchase/products/identifiers"
      expected_json = [prod_one.product_identifier, prod_two.product_identifier].to_json

      last_json.should be_json_eql expected_json
    end
  end

  describe " when I do a POST to /in_app_purchases/products" do
    it "should return a new product" do
      product = FactoryGirl.create(:inapp_product)
      expected_json = {:product => product.values}.to_json
      post "/in_app_purchase/products", product.values

      last_json.should be_json_eql expected_json
    end
  end

  describe "when I do a GET on /in_app_purchase/products/:product_identifier" do
    context "with a product that exists" do
      it "should return a product" do
        product = FactoryGirl.create(:inapp_product)
        expected_json = {:product => product.values}.to_json
        get "/in_app_purchase/products/#{product.product_identifier}"

        last_json.should be_json_eql expected_json
      end
    end
    context "with a product that doesn't exist" do
      it "should return a 404" do
        get "/in_app_purchase/products/com.fake.identifier"

        last_response.status.should be 404
      end
    end
  end

  describe "when I do a GET on /in_app_purchase/receipts" do
    before(:each) do
      10.times do
        FactoryGirl.create(:inapp_receipt)
      end
    end

    context "without pagination parameters" do
      it "should return a list of 10 receipts as json" do
        get "/in_app_purchase/receipts"

        json_hash["receipts"].count.should be 10
      end
    end

    context "with pagination parameters of 5 per page" do
      it "should return a list of 5 receipts as json" do
        get "/in_app_purchase/receipts?per_page=5"

        json_hash["receipts"].count.should be 5
      end
    end
  end

  describe "when I do a POST to /in_app_purchase/receipts/verify" do
    context "with valid receipt-data" do
      it "should return a 203" do
        receipt = FactoryGirl.build(:inapp_receipt)
        receipt_data = Base64.encode64(receipt.values.to_json)

        Venice::Client.any_instance.stub(:verify!).and_return(receipt)
        receipt.stub(:to_h).and_return(receipt.values)

        post "/in_app_purchase/receipts/verify", "receipt-data=#{receipt_data}", 'Content-Type' => 'x-www-formurlencoded'

        last_response.status.should be 203
      end
    end

    context "with invalid receipt-data" do
      it "should return a 400" do
        Venice::Receipt.stub(:verify!).with(anything).and_raise(Venice::Receipt::VerificationError.new(21002))
        post "/in_app_purchase/receipts/verify", "receipt-data=fakestuff", 'Content-Type' => 'x-www-formurlencoded'

        last_response.status.should be 400
      end
    end

    context "when a receipt is unable to be created with the given information" do
      it "should return a 500" do
        receipt = FactoryGirl.build(:inapp_receipt)
        receipt_data = Base64.encode64(receipt.values.to_json)

        Venice::Client.any_instance.stub(:verify!).and_return(receipt)
        post "/in_app_purchase/receipts/verify", "receipt-data=#{receipt_data}", 'Content-Type' => 'x-www-formurlencoded'

        last_response.status.should be 500
      end
    end
  end
end

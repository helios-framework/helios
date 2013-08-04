require 'spec_helper'

describe "Data Api" do
  describe "when I do a GET on /users" do
    it "should return a list of users" do
      user_one_json = FactoryGirl.create(:user).values.merge(:url => '/users/1')
      user_two_json = FactoryGirl.create(:user).values.merge(:url => '/users/2')
      expected_json = {:users => [user_one_json, user_two_json]}.to_json
      get "/users"

      last_json.should be_json_eql expected_json
    end
  end

  describe "when I do a POST to /users" do
    it "should return a new user" do
      expected_json = {:user => FactoryGirl.attributes_for(:user).merge(:url => '/users/1')}.to_json
      post "/users", FactoryGirl.build(:user).values

      last_json.should be_json_eql expected_json
    end
  end

  describe "when I do a PUT on /users/:id" do
    it "should return an updated user" do
      user = FactoryGirl.create(:user)
      user.email = 'something_new@example.com'
      expected_json = {:user => user.values.merge(:url => '/users/1')}.to_json
      put "/users/#{user.id}", user.values

      last_json.should be_json_eql expected_json
    end
  end

  describe "when I do a POST to /products" do
    context "with invalid product data" do
      it "should return a 400" do
        post "/products/", FactoryGirl.attributes_for(:invalid_product)

        last_response.status.should be 406
      end
    end
  end

  describe "when I do a DELETE on /users/:id" do
    it "should return a 200" do
      user = FactoryGirl.create(:user)
      delete "/users/#{user.id}"

      last_response.status.should be 200
    end
  end

  describe "when I do a GET on /users/:id" do
    context "with a user id that exists" do
      it "should return a single user" do
        user = FactoryGirl.create(:user)
        expected_json = {:user => {:email => 'bob@tester.com', :name => 'bob', :url => '/users/1'}}.to_json
        get "/users/#{user.id}"

        last_json.should be_json_eql expected_json
      end
    end
    context "with a user id that doesn't exist" do
      it "should return a 404" do
        get "/users/123456789"

        last_response.status.should be 404
      end
    end
  end

  describe "when I do an OPTIONS on /resources" do
    it "should return a list of available resources" do
      expected_json = [
        {
          :name => "Product", :url => "/products", :attributes => {
            :name => "String",
            :price => "Double",
            :productDescription =>"String",
            :quantity => "Integer 16"}
        },
        {
          :name => "User", :url => "/users", :attributes => {
            :email => "String",
            :name => "String"
          }
        }
      ].to_json
      options "/resources"

      last_json.should be_json_eql expected_json
    end
  end
end

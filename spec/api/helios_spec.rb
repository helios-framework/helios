require 'spec_helper'

describe "Helios Api" do
  describe "when I do a OPTIONS on /" do
    it "should return link headers for all services currently supported" do
      options "/", nil, { 'REQUEST_PATH' => '/', 'PATH_INFO' => '/' }

      last_response.headers["Link"].should_not be_nil
    end
  end

  describe "when I do a GET on /admin" do
    it "should request authentication credentials when they are set in the environment" do
      get "/admin"

      last_response.headers["WWW-Authenticate"].should_not be_nil
    end
  end
end

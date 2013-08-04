require 'spec_helper'

describe "Passbook Api" do
  describe "when I do a GET on /passbook/v1/passes/:passTypeIdentifier/:serialNumber" do
    context "with a valid pass identifier and serial number" do
      it "should return a passbook pass" do
        pass = FactoryGirl.create(:passbook_pass)
        get "/passbook/v1/passes/#{pass.pass_type_identifier}/#{pass.serial_number}", nil, 'HTTP_AUTHORIZATION' => "ApplePass #{pass.authentication_token}"

        last_response.status.should be 200
      end
    end

    context "without a valid pass identifier or serial number" do
      it "should return a 404 without a valid pass" do
        pass = FactoryGirl.create(:passbook_pass)
        get "/passbook/v1/passes/pass.com.fake.not.real/12345", nil, 'HTTP_AUTHORIZATION' => "ApplePass #{pass.authentication_token}"

        last_response.status.should be 404
      end
    end

    context "without valid credentials" do
      it "should return a 401 without valid credentials" do
        pass = FactoryGirl.create(:passbook_pass)
        get "/passbook/v1/passes/#{pass.pass_type_identifier}/#{pass.serial_number}", nil, 'HTTP_AUTHORIZATION' => "ApplePass not_real_token"

        last_response.status.should be 401
      end
    end
  end
  describe "when I do a GET on /passbook/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier[?passesUpdatedSince=tag]" do
    context "with a valid device library identifier and pass type identifier" do
      it "should return a list of serial numbers for a device" do
        registration = FactoryGirl.create(:passbook_registration)
        pass_one = Rack::Passbook::Pass.find(:id => registration.pass_id)
        get "/passbook/v1/devices/#{registration.device_library_identifier}/registrations/#{pass_one.pass_type_identifier}"

        json_hash["serialNumbers"].first.should == pass_one.serial_number
      end
    end

    context "without a valid pass type identifer or device library identifier" do
      it "should return a 404" do
        get "/passbook/v1/devices/fake_device/registrations/pass.com.fake.not.real"

        last_response.status.should be 404
      end
    end

    context "without any passes that meet the updated criteria" do
      it "should return a 204" do
        registration = FactoryGirl.create(:passbook_registration)
        pass_one = Rack::Passbook::Pass.find(:id => registration.pass_id)
        get "/passbook/v1/devices/#{registration.device_library_identifier}/registrations/#{pass_one.pass_type_identifier}/?passesUpdatedSince=#{Date.today.next_day}"

        last_response.status.should be 204
      end
    end
  end

  describe "when I do a POST to /passbook/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber" do
    context "with a new device" do
      it "should register a device to receive push notifications" do
        device_library_identifier = "bkshgjdfhgkjfdhkgh"
        push_token = "1234567890123456789012345678901234567890"
        pass = FactoryGirl.create(:passbook_pass)
        post "/passbook/v1/devices/#{device_library_identifier}/registrations/#{pass.pass_type_identifier}/#{pass.serial_number}/?pushToken=#{push_token}", nil, 'HTTP_AUTHORIZATION' => "ApplePass #{pass.authentication_token}"

        last_response.status.should be 201
      end
    end

    context "with an already existing devices" do
      it "should reregister a device to receive push notifications" do
        registration = FactoryGirl.create(:passbook_registration)
        pass = Rack::Passbook::Pass.find(:id => registration.pass_id)
        post "/passbook/v1/devices/#{registration.device_library_identifier}/registrations/#{pass.pass_type_identifier}/#{pass.serial_number}/?pushToken=#{registration.push_token}", nil, 'HTTP_AUTHORIZATION' => "ApplePass #{pass.authentication_token}"

        last_response.status.should be 200
      end
    end

    context "without valid security credentials" do
      it "should return a 401" do
        device_library_identifier = "bkshgjdfhgkjfdhkgh"
        push_token = "1234567890123456789012345678901234567890"
        pass = FactoryGirl.create(:passbook_pass)
        post "/passbook/v1/devices/#{device_library_identifier}/registrations/#{pass.pass_type_identifier}/#{pass.serial_number}/?pushToken=#{push_token}"

        last_response.status.should be 401
      end
    end

    context "without a valid pass" do
      it "should return a 404" do
        post "/passbook/v1/devices/gibberish/registrations/pass.com.fake.not.exist/12345/?pushToken=12345"

        last_response.status.should be 404
      end
    end

    context "without a valid registration" do
      it "should return a 406" do
        device_library_identifier = "bkshgjdfhgkjfdhkgh"
        push_token = "1"
        pass = FactoryGirl.create(:passbook_pass)
        post "/passbook/v1/devices/#{device_library_identifier}/registrations/#{pass.pass_type_identifier}/#{pass.serial_number}/?pushToken=#{push_token}", nil, 'HTTP_AUTHORIZATION' => "ApplePass #{pass.authentication_token}"

        last_response.status.should be 406
      end
    end
  end

  describe "when I do a DELETE on /passbook/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber" do
    context "with an existing device" do
      it "should return a 200 and unregister the device" do
        registration = FactoryGirl.create(:passbook_registration)
        pass = Rack::Passbook::Pass.find(:id => registration.pass_id)
        delete "/passbook/v1/devices/#{registration.device_library_identifier}/registrations/#{pass.pass_type_identifier}/#{pass.serial_number}", nil, 'HTTP_AUTHORIZATION' => "ApplePass #{pass.authentication_token}"

        last_response.status.should be 200
      end
    end

    context "with an invalid pass" do
      it "should return a 404" do
        pass = FactoryGirl.build(:passbook_pass)
        delete "/passbook/v1/devices/gibberish/registrations/pass.com.fake.not.real/12345", nil, 'HTTP_AUTHORIZATION' => "ApplePass #{pass.authentication_token}"

        last_response.status.should be 404
      end
    end

    context "with an invalid authentication token" do
      it "should return a 401" do
        registration = FactoryGirl.create(:passbook_registration)
        pass = Rack::Passbook::Pass.find(:id => registration.pass_id)
        delete "/passbook/v1/devices/#{registration.device_library_identifier}/registrations/#{pass.pass_type_identifier}/#{pass.serial_number}", nil, 'HTTP_AUTHORIZATION' => "ApplePass not_real_token"

        last_response.status.should be 401
      end
    end
  end

  describe "when I do a GET on /passes" do
    before(:each) do
      10.times do
        FactoryGirl.create(:passbook_registration)
      end
    end

    context "without any pagination params" do
      it "should return a list of passes as json" do
        get "/passbook/passes"

        json_hash["passes"].count.should be 10
      end
    end

    context "with pagination parameters of 5 per page" do
      it "should return a list of 5 devices" do
        get "/passbook/passes?per_page=5"

        json_hash["passes"].count.should be 5
      end
    end
  end
end

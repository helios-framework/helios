require 'spec_helper'

describe "Push Notification Api" do
  describe "when I do a PUT on /push_notification/devices" do
    context "with a valid new device" do
      it "should return a new device" do
        device = FactoryGirl.attributes_for(:device).merge(:alias => 'alias')
        put "/push_notification/devices", device

        json_hash["device"]["alias"].should == device[:alias]
      end
    end

    context "with valid device values" do
      it "should update an existing device" do
        device = FactoryGirl.create(:device)
        device.values.merge({
          :tags => ['iPhone 5S', '6.1'],
        })
        put "/push_notification/devices", device.values

        json_hash["device"]["tags"].should_not be_nil
      end
    end

    context "with an invalid device" do
      it "should return a 400" do
        device = FactoryGirl.attributes_for(:device)
        device[:token] = 'not gonna work'
        put "/push_notification/devices", device

        last_response.status.should be 400
      end
    end
  end

  describe "when I do a GET on /push_notification/devices" do
    context "with pagination parameters of 5 per page" do
      it "should return a paginated list of 5 devices with 10 total" do
        10.times do
          FactoryGirl.create(:device)
        end
        get "/push_notification/devices?per_page=5"

        json_hash["devices"].count.should be 5
      end
    end
    context "without pagination parameters" do
      it "should return a list of devices" do
        FactoryGirl.create(:device)
        get "/push_notification/devices"

        json_hash["devices"].should_not be_nil
      end
    end
  end

  describe "when I do a GET on /push_notification/devices/:token" do
    context "with a valid device token" do
      it "should return a device" do
        device = FactoryGirl.create(:device)
        token = device.token.strip.gsub(/[<\s>]/, '')
        get "/push_notification/devices/#{token}"

        json_hash["device"].should_not be_nil
      end
    end

    context "without a valid device token" do
      it "should return a 404" do
        get "/push_notification/devices/notrealtokenvalue"

        last_response.status.should be 404
      end
    end
  end

  describe "when I do a DELETE on /device/:token" do
    context "with a valid device token" do
      it "should return a 200" do
        device = FactoryGirl.create(:device)
        delete "/push_notification/devices/#{device.token}"

        last_response.status.should be 200
      end
    end
  end

  describe "when I do a POST on /push_notification/message" do
    context "with valid tokens" do
      it "should send a push notification" do
        devices = Array.new

        3.times do
          devices << FactoryGirl.create(:device)
        end

        Houston::Client.any_instance.stub(:push).and_return(true)

        tokens = devices.collect { |device| device.token + ',' }
        post "/push_notification/message", 'payload={"aps":{"alert":"hello"}}&tokens=' + "#{tokens}", 'Content-Type' => 'x-www-formurlencoded'

        last_response.status.should be 204
      end
    end

    context "without valid tokens" do
      it "should return a 500" do
        tokens = "12345678901234567890,12345678912345678901,12345678901234567890,"
        Houston::Notification.stub(:new).and_raise(StandardError)
        post "/push_notification/message", 'payload={"aps":{"alert":"hello"}}&tokens=' + "#{tokens}", 'Content-Type' => 'x-www-formurlencoded'

        last_response.status.should be 500
      end
    end
  end

  describe "when I do a HEAD on /push_notification/message" do
    context "with a valid apn client" do
      it "should return a 204" do
        head "/push_notification/message"

        last_response.status.should be 204
      end
    end
  end
end

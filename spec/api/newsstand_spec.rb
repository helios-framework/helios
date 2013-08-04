require 'spec_helper'

describe "Newsstand Api" do
  before(:all) do
    Fog.mock!
  end

  describe "when I do a GET on /newsstand/issues" do
    context "requesting json data be returned" do
      before(:each) do
        10.times do
          FactoryGirl.create(:newsstand_issue)
        end
      end

      context "without pagination parameters" do
        it "should return a list of issues as json" do
          get "/newsstand/issues", nil, 'HTTP_ACCEPT' => 'application/json'

          json_hash["issues"].count.should be 10
        end
      end

      context "with pagination parameters" do
        it "should return a paginated list of issues as json" do
          get "/newsstand/issues?per_page=5", nil, 'HTTP_ACCEPT' => 'application/json'

          json_hash["issues"].count.should be 5
        end
      end
    end

    context "requesting an atom feed be returned" do
      it "should return a list of issues as an atom feed" do
        get "/newsstand/issues", nil, 'HTTP_ACCEPT' => 'application/atom+xml'

        last_response.status.should be 200
      end
    end

    context "requesting a plist be returned" do
      it "should return a plist of issues" do
        get "/newsstand/issues", nil, 'HTTP_ACCEPT' => 'application/x-plist'

        last_response.status.should be 200
      end
    end

    context "requesting a type that isn't supported" do
      it "should return a 406" do
        get "/newsstand/issues", nil, 'HTTP_ACCEPT' => 'application/totally-made-up'

        last_response.status.should be 406
      end
    end
  end

  describe "when I do a HEAD on /newsstand/storage" do
    context "with valid storage credentials configured" do
      it "should return a 204" do
        head "/newsstand/storage"

        last_response.status.should be 204
      end
    end
  end

  describe "when I do a GET on /newsstand/issues/:name" do
    it "should return an Issue" do
      issue = FactoryGirl.create(:newsstand_issue)
      expected_json = issue.to_json
      get "/newsstand/issues/#{issue.name}", nil, 'HTTP_ACCEPT' => 'application/json'

      last_json.should be_json_eql expected_json
    end
  end

  describe "when I do a POST to /newsstand/issues" do
    context "with valid issue data" do
      it "should return a new issue" do
        file = File.open('example/trollface.jpg', 'r') { |f| Base64.encode64(f.read) }
        assets = [{:filename => 'trollface.jpg', :tempfile => file}]
        covers = [{:filename => 'trollface.jpg', :tempfile => file}]

        issue = FactoryGirl.attributes_for(:newsstand_issue).merge({
          :assets => assets,
          :covers => covers,
        })
        post "/newsstand/issues", issue, 'HTTP_ACCEPT' => 'application/json'
        issue = Rack::Newsstand::Issue.find(name: issue[:name]).values.to_json

        last_json.should be_json_eql issue
      end
    end

    context "without valid issue data" do
      it "should return a 400" do
        issue = FactoryGirl.attributes_for(:newsstand_issue)
        issue[:published_at] = nil
        post "/newsstand/issues", issue, 'HTTP_ACCEPT' => 'application/json'

        last_response.status.should be 400
      end
    end
  end
end

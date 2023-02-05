require "functions_framework/testing"

RSpec.describe FunctionsFramework do
  include FunctionsFramework::Testing

  describe ".on_startup" do
    subject { load_temporary("app.rb") { run_startup_tasks "status" } }

    it "should initialize instance variables" do
      expect(subject[:status].instance_variables).to include :@bearer_token
      expect(subject[:status].instance_variables).to include :@refresh_time
    end
  end

  describe ".http" do
    let(:method) { "GET" }
    let(:request) { make_request "/status", method: method }

    subject { load_temporary("app.rb") { call_http "status", request } }

    context "with an OPTIONS request" do
      let(:method) { "OPTIONS" }

      it "should return 204 with OPTS headers" do
        expect(subject.status).to eq 204
        expect(subject.body).to be_empty
        expect(subject.headers).to eq Status::OPTS_HEADERS
      end
    end

    context "with invalid twitter response" do
      before { expect(Net::HTTP).to receive(:get_response) }

      it "should return 500 with failure message" do
        expect(subject.status).to eq 500
        expect(subject.body).to eq ["Something went wrong."]
      end
    end

    context "with valid twitter response" do
      let(:resp) { Net::HTTPSuccess.new(1.0, "200", "OK") }
      # let(:data) { {"data" => []}.to_json }
      let(:data) { '<html><body><div class="view-tweets"></div></body></html>' }

      before do
        expect(Net::HTTP).to receive(:get_response).and_return(resp)
        expect(resp).to receive(:body).and_return(data)
      end

      it "should return 200 with CORS headers" do
        expect(subject.status).to eq 200
        expect(subject.body).to eq [{"message" => ""}.to_json]
        expect(subject.content_type).to eq "application/json; charset=utf-8"
        expect(subject.headers).to eq Status::CORS_HEADERS
      end
    end
  end
end

require "functions_framework/testing"

describe FunctionsFramework do
  include FunctionsFramework::Testing

  context "with an OPTIONS request" do
    let(:method) { "OPTIONS" }

    it "should return 204 with OPTS headers" do
      load_temporary "app.rb" do
        request = make_request "/status", method: method
        response = call_http "status", request
        expect(response.status).to eq 204
        expect(response.headers).to eq Status::OPTS_HEADERS
      end
    end
  end

  context "with broken twitter response" do
    before { expect(Net::HTTP).to receive(:get_response) }

    it "should invalid 500 with failure message" do
      load_temporary "app.rb" do
        request = make_get_request "/status"
        response = call_http "status", request
        expect(response.status).to eq 500
        expect(response.body).to eq ["Something went wrong."]
      end
    end
  end

  context "with valid twitter response" do
    let(:resp) { Net::HTTPSuccess.new(1.0, "200", "OK") }
    let(:data) { {"data" => []}.to_json }
    let(:body) { [{"message" => ""}.to_json] }

    before do
      expect(Net::HTTP).to receive(:get_response).and_return(resp)
      expect(resp).to receive(:body).and_return(data)
    end

    it "should return 200 with CORS headers" do
      load_temporary "app.rb" do
        request = make_get_request "/status"
        response = call_http "status", request
        expect(response.status).to eq 200
        expect(response.body).to eq body
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response.headers).to eq Status::CORS_HEADERS
      end
    end
  end
end

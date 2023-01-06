require "status"

RSpec.describe Status do
  describe "::OPTS_HEADERS" do
    let(:hash) { Status::OPTS_HEADERS }

    it "should include expected key" do
      expect(hash.is_a?(Hash)).to be(true)
      expect(hash.key?("Access-Control-Allow-Origin")).to be(true)
    end
  end

  describe "::CORS_HEADERS" do
    let(:hash) { Status::CORS_HEADERS }

    it "should include expected key" do
      expect(hash.is_a?(Hash)).to be(true)
      expect(hash.key?("Access-Control-Allow-Origin")).to be(true)
    end
  end

  describe "#message" do
    let(:msg0) { "We're waiting for electrification." }
    let(:msg1) { "Train 432 SB is running 9 minutes late approaching Nirvana." }
    let(:msg2) { "SB514 boarding on the northbound platform Santa Clara." }
    let(:msg3) { "We're working on electrification." }
    let(:msg4) { "We're starting with electrification." }
    let(:recent) { Time.now - 22222 }
    let(:past) { Time.now - 33333 }
    let(:payload) {
      {"data" => [
        {"created_at" => time, "text" => msg0},
        {"created_at" => time, "text" => msg1},
        {"created_at" => time, "text" => msg2},
        {"created_at" => time, "text" => msg3},
        {"created_at" => past, "text" => msg4}
      ]}.to_json
    }
    let(:resp) { Net::HTTPSuccess.new(1.0, "200", "OK") }
    let(:train_id) { "321" }

    context "with invalid twitter response" do
      before { expect(Net::HTTP).to receive(:get_response) }

      it "should return nil" do
        expect(subject.message(train_id)).to be_nil
      end
    end

    context "with valid twitter response" do
      before(:each) do
        expect(Net::HTTP).to receive(:get_response).and_return(resp)
        expect(resp).to receive(:body).and_return(payload)
      end

      context "with stale messages" do
        let(:time) { past }

        it "should return empty string" do
          expect(subject.message(train_id)).to be_empty
        end
      end

      context "with recent messages" do
        let(:time) { recent }

        context "with just train ID in the feed" do
          let(:train_id) { "432" }

          it "should return expected response" do
            expect(subject.message(train_id)).to eq(msg1)
          end
        end

        context "with train combo ID in the feed" do
          let(:train_id) { "514" }

          it "should return expected response" do
            expect(subject.message(train_id)).to eq(msg2)
          end
        end

        context "without train ID in the feed" do
          let(:train_id) { "123" }

          it "should return expected response" do
            expect(subject.message(train_id)).to eq(msg0)
          end
        end
      end
    end
  end

  describe "#status_tweets" do
    it "should encode query params" do
      expect(Net::HTTP).to receive(:get_response)
      expect(URI).to receive(:encode_www_form)
      subject.send(:status_tweets)
    end
  end
end

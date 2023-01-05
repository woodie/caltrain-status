require "status"

RSpec.describe Status do
  describe "OPTS_HEADERS" do
    let(:hash) { Status::OPTS_HEADERS }

    it "should include expected key" do
      expect(hash.is_a?(Hash)).to be(true)
      expect(hash.key?("Access-Control-Allow-Origin")).to be(true)
    end
  end

  describe "RESP_HEADERS" do
    let(:hash) { Status::RESP_HEADERS }

    it "should include expected key" do
      expect(hash.is_a?(Hash)).to be(true)
      expect(hash.key?("Access-Control-Allow-Origin")).to be(true)
    end
  end

  describe ".message" do
    let(:msg0) { "We're waiting for electrification." }
    let(:msg1) { "Train 432 SB is running 9 minutes late approaching Nirvana." }
    let(:msg2) { "SB514 boarding on the northbound platform Santa Clara." }
    let(:msg3) { "We're done with electrification." }
    let(:payload) {
      {"data" => [
        {"created_at" => time, "text" => msg0},
        {"created_at" => time, "text" => msg1},
        {"created_at" => time, "text" => msg2},
        {"created_at" => time, "text" => msg3}
      ]}.to_json
    }
    let(:response) { Net::HTTPSuccess.new(1.0, "200", "OK") }
    let(:train_id) { "321" }

    context "with bad response" do
      before(:each) { expect(Net::HTTP).to receive(:get_response) }

      it "should return nil" do
        expect(subject.message(train_id)).to be_nil
      end
    end

    context "with a valid response" do
      before(:each) do
        expect(Net::HTTP).to receive(:get_response).and_return(response)
        expect(response).to receive(:body).and_return(payload)
      end

      context "with stale messages" do
        let(:time) { Time.now - 33333 }

        it "should return empty string" do
          expect(subject.message(train_id)).to be_empty
        end
      end

      context "with recent messages" do
        let(:time) { Time.now - 22222 }

        context "with just train_d in the feed" do
          let(:train_id) { "432" }

          it "should return message when response" do
            expect(subject.message(train_id)).to eq(msg1)
          end
        end

        context "with combo train_id in the feed" do
          let(:train_id) { "514" }

          it "should return message when response" do
            expect(subject.message(train_id)).to eq(msg2)
          end
        end

        context "without train in the feed" do
          let(:train_id) { "123" }

          it "should return message when response" do
            expect(subject.message(train_id)).to eq(msg0)
          end
        end
      end
    end
  end
end

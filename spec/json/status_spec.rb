require "spec_helper"

describe Datatrans::JSON::Transaction::Status do
  before do
    @successful_response = {
      "transactionId" => "230208152524486347",
      "merchantId" => "1100000000",
      "type" => "payment",
      "status" => "settled",
      "currency" => "CHF",
      "refno" => "nX0S1dytA",
      "paymentMethod" => "VIS",
      "detail" => {
        "authorize" => {}
      },
      "card" => {
        "masked" => "424242xxxxxx4242",
        "expiryMonth" => "06",
        "expiryYear" => "25",
        "info" => {}
      },
      "history" => [
        {
          "action" => "authorize",
          "amount" => 1000,
          "source" => "api",
          "date" => "2023-02-08T14:25:24Z",
          "success" => true,
          "ip" => "77.109.165.195"
        }
      ]
    }

    @failed_response = {
      "error" => {
        "code" => "INVALID_PROPERTY",
        "message" => "status transactionId length must be 18 digits"
      }
    }

    @valid_params = {
      transaction_id: '230208152524486347',
    }

    @invalid_params = {
      transaction_id: '0208152524486347',
    }
  end

  context "successful response" do
    before do
      allow_any_instance_of(Datatrans::JSON::Transaction::Status).to receive(:process).and_return(@successful_response)
    end

    it "#process handles a valid datatrans status response" do
      transaction = Datatrans::JSON::Transaction.new(@datatrans, @valid_params)
      expect(transaction.status).to be true
      expect(transaction.response.params["refno"]).to eq "nX0S1dytA"
      expect(transaction.response.params["paymentMethod"]).to eq "VIS"
    end
  end

  context "failed response" do
    before do
      allow_any_instance_of(Datatrans::JSON::Transaction::Status).to receive(:process).and_return(@failed_response)
      @transaction = Datatrans::JSON::Transaction.new(@datatrans, @invalid_params)
    end

    it "handles a failed datatrans status response" do
      expect(@transaction.status).to be false
      expect(@transaction.response.error_code).to eq "INVALID_PROPERTY"
      expect(@transaction.response.error_message).to eq "status transactionId length must be 18 digits"
    end
  end
end

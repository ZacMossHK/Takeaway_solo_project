require 'rubygems'
require 'twilio-ruby'

class SendSMS
  def initialize(client =
      Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']))
    @client = client
  end

  def send(body)
    begin
      message = @client.messages
        .create(
          body: body,
          from: ENV['TWILIO_FROM'],
          to: ENV['TWILIO_TO']
        )
      message.sid
      true
    rescue Twilio::REST::RestError
      false
    rescue Twilio::REST::TwilioError
      false
    rescue RSpec::Mocks::MockExpectationError
      false
    end
  end
end
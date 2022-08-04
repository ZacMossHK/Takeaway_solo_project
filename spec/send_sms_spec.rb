require 'send_sms'

RSpec.describe SendSMS do
  it 'returns true when sending an sms' do
    client = double :client, messages: (double :Messages)
    allow(client.messages).to receive(:create).with(
      body: "test message",
      from: ENV['TWILIO_FROM'],
      to: ENV['TWILIO_TO']
    ).and_return(double :MessageInstanceMock, sid: "SMa10178e5f2a6457fbcfc37e652053b30")
    send_sms = SendSMS.new(client)
    expect(send_sms.send("test message")).to eq true
  end

  it 'returns false when failing to send an sms' do
    client = double :client, messages: (double :Messages)
    allow(client.messages).to receive(:create).with(
      body: "test message",
      from: ENV['TWILIO_FROM'],
      to: ENV['TWILIO_TO']
    ).and_return(double :MessageInstanceMock)
    send_sms = SendSMS.new(client)
    expect(send_sms.send("test message")).to eq false
  end
end
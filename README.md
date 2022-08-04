# Takeaway_solo_project
My first solo project at Maker's emulating a takeaway, uses RSpec for testing and Twilio for confirmation SMS messages. Written in Ruby.

Orders are placed in Takeaway.rb, using SendSMS.rb to send SMS messages to the customer. If a .sid is received from the MessageInstance object the Twilio client returns when you use Twilio's API, the SMS is considered delivered and the customer is returned a string declaring they have been sent a confirmation SMS. If there is an error with Twilio then the customer is told there has been an issue sending them an SMS.

Order times are set to 40 minutes, which can be changed in the Takeaway.arrival_time method.

To order with Twilio environment variables must be set for the following variables:

ENV['TWILIO_ACCOUNT_SID'] = Your Twilio account SID

ENV['TWILIO_AUTH_TOKEN'] = Your Twilio authentication

ENV['TWILIO_FROM'] = Your virtual phone number from Twilio

ENV['TWILIO_TO'] = The message recepient's number

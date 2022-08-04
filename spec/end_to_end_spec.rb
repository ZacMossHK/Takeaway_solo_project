require 'takeaway'
require 'send_sms'
require 'menu'
require 'dish'

RSpec.describe "end to end" do
  xit "sends the customer an SMS after ordering and returns a confirmation string" do
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    send_sms = SendSMS.new
    dish_1 = Dish.new("Fries", 4.0)
    dish_2 = Dish.new("Chicken satay", 8.99)
    dish_3 = Dish.new("Steak", 19.99)
    menu.add(dish_1)
    menu.add(dish_2)
    menu.add(dish_3)
    takeaway.select_dish(dish_1)
    takeaway.select_dish(dish_2)
    takeaway.select_dish(dish_3)
    time = (Time.now + 2400).strftime('%H:%M') # adds 40 minutes
    order_str = "Thank you for ordering! Your order comes to £32.98 and will be with you by #{time}."
    confirmation_str = " You should receive an SMS with order details in the next few minutes."
    expect(takeaway.order(send_sms)).to eq order_str + confirmation_str
  end
end

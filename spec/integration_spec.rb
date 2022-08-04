require 'takeaway'
require 'send_sms'
require 'menu'
require 'dish'

RSpec.describe 'integration' do
  it "returns an empty menu if no dishes are added" do
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    expect(takeaway.menu).to eq []
  end

  it "adds dishes to menu" do
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    dish_1 = Dish.new("Fries", 4.0)
    dish_2 = Dish.new("Chicken satay", 8.99)
    dish_3 = Dish.new("Steak", 19.99)
    menu.add(dish_1)
    menu.add(dish_2)
    menu.add(dish_3)
    expect(takeaway.menu).to eq [dish_1, dish_2, dish_3]
  end

  it "fails if selected dish not on menu" do
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    dish_1 = Dish.new("Fries", 4.0)
    expect { takeaway.select_dish(dish_1) }.to raise_error "Dish not on menu"
  end

  it "deselects dishes and removes from basket" do
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    dish_1 = Dish.new("Fries", 4.0)
    dish_2 = Dish.new("Chicken satay", 8.99)
    dish_3 = Dish.new("Steak", 19.99)
    menu.add(dish_1)
    menu.add(dish_2)
    menu.add(dish_3)
    takeaway.select_dish(dish_1)
    takeaway.select_dish(dish_2)
    takeaway.select_dish(dish_3)
    expect(takeaway.basket).to eq [dish_1, dish_2, dish_3]
    takeaway.deselect_dish(dish_2)
    expect(takeaway.basket).to eq [dish_1, dish_3]
  end

  it "fails deselect if dish not on menu" do
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    dish_1 = Dish.new("Fries", 4.0)
    expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not on menu"
  end

  it "fails deselect if dish not in basket" do
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    dish_1 = Dish.new("Fries", 4.0)
    menu.add(dish_1)
    expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not in basket"
  end

  it "returns an itemised receipt" do
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    dish_1 = Dish.new("Fries", 4.0)
    dish_2 = Dish.new("Chicken satay", 8.99)
    dish_3 = Dish.new("Steak", 19.99)
    menu.add(dish_1)
    menu.add(dish_2)
    menu.add(dish_3)
    takeaway.select_dish(dish_1)
    takeaway.select_dish(dish_2)
    takeaway.select_dish(dish_3)
    expect(takeaway.receipt).to eq "Fries: £4.00, Chicken satay: £8.99, Steak: £19.99, TOTAL: £32.98"
  end

  it "returns empty string if nothing added" do
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    expect(takeaway.receipt).to eq ""
  end

  it "fails to order if basket is empty" do
    send_sms = SendSMS.new(double :client)
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    expect { takeaway.order(send_sms) }.to raise_error "Cannot order when basket is empty"
  end

  it "sends the customer an SMS after ordering and returns a confirmation string" do
    client = double :client, messages: (double :Messages)
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    send_sms = SendSMS.new(client)
    dish_1 = Dish.new("Fries", 4.0)
    dish_2 = Dish.new("Chicken satay", 8.99)
    dish_3 = Dish.new("Steak", 19.99)
    menu.add(dish_1)
    menu.add(dish_2)
    menu.add(dish_3)
    takeaway.select_dish(dish_1)
    takeaway.select_dish(dish_2)
    takeaway.select_dish(dish_3)
    body_str = "Thank you for ordering! Your order comes to £32.98 and will be with you by 21:00."
    allow(client.messages).to receive(:create).with(
      body: body_str,
      from: ENV['TWILIO_FROM'],
      to: ENV['TWILIO_TO']
    ).and_return(double :MessageInstanceMock, sid: "SMa10178e5f2a6457fbcfc37e652053b30")
    confirmation_str = " You should receive an SMS with order details in the next few minutes."
    time = Time.new(2022, 1, 8, 20, 20, 0)
    expect(takeaway.order(send_sms, time)).to eq body_str + confirmation_str
  end

  it "fails to send the customer an SMS" do
    client = double :client, messages: (double :Messages)
    menu = Menu.new
    takeaway = Takeaway.new(menu)
    send_sms = SendSMS.new(client)
    dish_1 = Dish.new("Fries", 4.0)
    dish_2 = Dish.new("Chicken satay", 8.99)
    dish_3 = Dish.new("Steak", 19.99)
    menu.add(dish_1)
    menu.add(dish_2)
    menu.add(dish_3)
    takeaway.select_dish(dish_1)
    takeaway.select_dish(dish_2)
    takeaway.select_dish(dish_3)
    body_str = "Thank you for ordering! Your order comes to £32.98 and will be with you by 21:00."
    allow(client.messages).to receive(:create).with(
      body:body_str,
      from: ENV['TWILIO_FROM'],
      to: ENV['TWILIO_TO']
    ).and_return(double :MessageInstanceMock)
    fail_str =  " There has been an issue sending you a confirmation SMS."
    time = Time.new(2022, 1, 8, 20, 20, 0)
    expect(takeaway.order(send_sms, time)).to eq body_str + fail_str
  end
end
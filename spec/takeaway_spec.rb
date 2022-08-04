require 'takeaway'

RSpec.describe Takeaway do
  it "returns an empty list if nothing is added" do
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    expect(menu).to receive(:all).and_return([])
    expect(takeaway.menu).to eq []
  end

  it "returns empty list when calling baskset if nothing added" do
    takeaway = Takeaway.new(double :Menu)
    expect(takeaway.basket).to eq []
  end 

  it "returns a menu with dishes" do
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    dish_1 = double :Dish, name: "Fries", price: 4.0
    dish_2 = double :Dish, name: "Chicken satay", price: 8.99
    dish_3 = double :Dish, name: "Steak", price: 19.99
    expect(menu).to receive(:all).and_return([dish_1, dish_2, dish_3])
    expect(takeaway.menu).to eq [dish_1, dish_2, dish_3]
  end

  it "selects dishes and adds to basket" do
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    dish_1 = double :Dish, name: "Fries", price: 4.0
    dish_2 = double :Dish, name: "Chicken satay", price: 8.99
    dish_3 = double :Dish, name: "Steak", price: 19.99
    allow(menu).to receive(:all).and_return([dish_1, dish_2, dish_3])
    takeaway.select_dish(dish_1)
    takeaway.select_dish(dish_2)
    takeaway.select_dish(dish_3)
    expect(takeaway.basket).to eq [dish_1, dish_2, dish_3]
  end

  it "fails if selected dish not on menu" do
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    dish_1 = double :Dish, name: "Fries", price: 4.0
    dish_2 = double :Dish, name: "Chicken satay", price: 8.99
    allow(menu).to receive(:all).and_return([dish_2])
    expect { takeaway.select_dish(dish_1) }.to raise_error "Dish not on menu"
  end

  it "deselects dishes and removes from basket" do
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    dish_1 = double :Dish, name: "Fries", price: 4.0
    dish_2 = double :Dish, name: "Chicken satay", price: 8.99
    dish_3 = double :Dish, name: "Steak", price: 19.99
    allow(menu).to receive(:all).and_return([dish_1, dish_2, dish_3])
    takeaway.select_dish(dish_1)
    takeaway.select_dish(dish_2)
    takeaway.select_dish(dish_3)
    expect(takeaway.basket).to eq [dish_1, dish_2, dish_3]
    takeaway.deselect_dish(dish_2)
    expect(takeaway.basket).to eq [dish_1,dish_3]
  end

  it "fails deselect if dish not on menu" do
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    dish_1 = double :Dish, name: "Fries", price: 4.0
    allow(menu).to receive(:all).and_return([])
    expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not on menu"
  end

  it "deselect fails if dish not in basket" do
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    dish_1 = double :Dish, name: "Fries", price: 4.0
    allow(menu).to receive(:all).and_return([dish_1])
    expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not in basket"
  end

  it "returns an itemised receipt" do
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    dish_1 = double :Dish, name: "Fries", price: 4.0
    dish_2 = double :Dish, name: "Chicken satay", price: 8.99
    dish_3 = double :Dish, name: "Steak", price: 19.99
    allow(menu).to receive(:all).and_return([dish_1, dish_2, dish_3])
    takeaway.select_dish(dish_1)
    takeaway.select_dish(dish_2)
    takeaway.select_dish(dish_3)
    receipt_str = "Fries: £4.00, Chicken satay: £8.99, Steak: £19.99, TOTAL: £32.98"
    expect(takeaway.receipt).to eq receipt_str
  end

  it "returns empty string if nothing added" do
    takeaway = Takeaway.new(double :Menu)
    expect(takeaway.receipt).to eq ""
  end

  it "fails to order if basket is empty" do
    send_sms = double :SendSMS
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    expect { takeaway.order(send_sms) }.to raise_error "Cannot order when basket is empty"
  end

  it "sends the customer an SMS after ordering and returns a confirmation string" do
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    send_sms = double :SendSMS
    dish_1 = double :Dish, name: "Fries", price: 4.0
    dish_2 = double :Dish, name: "Chicken satay", price: 8.99
    dish_3 = double :Dish, name: "Steak", price: 19.99
    allow(menu).to receive(:all).and_return([dish_1, dish_2, dish_3])
    takeaway.select_dish(dish_1)
    takeaway.select_dish(dish_2)
    takeaway.select_dish(dish_3)
    order_str = "Thank you for ordering! Your order comes to £32.98 and will be with you by 21:00."
    expect(send_sms).to receive(:send)
      .with(order_str)
      .and_return(true)
    time = Time.new(2022, 1, 8, 20, 20, 0)
    confirmation_str = " You should receive an SMS with order details in the next few minutes."
    expect(takeaway.order(send_sms, time)).to eq order_str + confirmation_str
  end
  
  it "fails to send the customer an SMS" do
    menu = double :Menu
    takeaway = Takeaway.new(menu)
    send_sms = double :SendSMS
    dish_1 = double :Dish, name: "Fries", price: 4.0
    dish_2 = double :Dish, name: "Chicken satay", price: 8.99
    dish_3 = double :Dish, name: "Steak", price: 19.99
    allow(menu).to receive(:all).and_return([dish_1, dish_2, dish_3])
    takeaway.select_dish(dish_1)
    takeaway.select_dish(dish_2)
    takeaway.select_dish(dish_3)
    order_str = "Thank you for ordering! Your order comes to £32.98 and will be with you by 21:00."
    expect(send_sms).to receive(:send)
      .with(order_str)
      .and_return(false)
    time = Time.new(2022, 1, 8, 20, 20, 0)
    fail_str = " There has been an issue sending you a confirmation SMS."
    expect(takeaway.order(send_sms, time)).to eq order_str + fail_str
  end
end
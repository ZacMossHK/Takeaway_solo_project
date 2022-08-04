# {{PROBLEM}} Multi-Class Planned Design Recipe

## 1. Describe the Problem

_Put or write the user story here. Add any clarifying notes you might have._

As a customer
So that I can check if I want to order something
I would like to see a list of dishes with prices.

> order, see
> user wants to call a list of dishes with prices

As a customer
So that I can order the meal I want
I would like to be able to select some number of several available dishes.

> order, select
> user wants to select some of the dishes
> return a selected list

As a customer
So that I can verify that my order is correct
I would like to see an itemised receipt with a grand total.

> verify, see
> return a string formatted from the list with a sum total

> Use the twilio-ruby gem to implement this next one. You will need to use doubles too.

As a customer
So that I am reassured that my order will be delivered on time
I would like to receive a text such as "Thank you! Your order was placed and will be delivered before 18:52" after I have ordered.

> receive
> Twilio sends the user an sms after they order



## 2. Design the Class System

```ruby
class Takeaway
  def initialize
    # ...
  end

  def menu
    # if no dishes are in menu, returns empty list
    # otherwise returns a list of Dish instances
  end

  def select_dish(dish) # dish is an instance of Dish
    # fails if dish not on menu
    # otherwise adds dish to list of selected dishes
    # returns nothing
  end

  def deselect_dish(dish) # dish is an instance of Dish
    # fails if dish isn't in basket
    # otherwise removes dish to list of selected dishes
    # returns nothing
  end

  def basket
    # if no dishes have been added, returns empty list
    # otherwise returns list of selected Dish instances
  end

  def receipt
    # if basket is empty, returns empty string
    # otherwise returns string of itemised receipt of Dish instance titles and prices in basket
  end

  def order
    # fails if basket is empty
    # otherwise sends SMS to customer confirming order through SendSMS class
    # returns string "Thank you for ordering!"
  end
end

class Menu
  def initialize
    # ...
  end

  def add(dish) # dish is an instance of Dish
    # adds to list
    # returns nothing
  end

  def all
    # returns empty list if no dishes are added
    # otherwise returns list of dish instances
  end
end

class SendSMS
  def initialize
    # ...
  end
  
  def send(total)
    # sends the customer an SMS with twilio confirming order
  end

  private

  def twilio(message)
    # contains the code running twilio
  end
end
  
Dish = Struct.new(:name, :price)
```

## 3. Create Examples as Integration Tests

_Create examples of the classes being used together in different situations and
combinations that reflect the ways in which the system will be used._

```ruby
# menu returns empty list if nothing added
menu = menu.new
takeaway = Takeaway.new(menu)
expect(takeaway.menu).to eq []

# adds to menu
menu = Menu.new
takeaway = Takeaway.new(menu)
dish_1 = Dish.new("Fries", 4.0)
dish_2 = Dish.new("Chicken satay", 8.99)
dish_3 = Dish.new("Steak", 19.99)
menu.add(dish_1)
menu.add(dish_2)
menu.add(dish_3)
expect(takeaway.menu(menu)).to eq [dish_1, dish_2, dish_3]

# fails if selected dish not on menu
menu = Menu.new
takeaway = Takeaway.new(menu)
dish_1 = Dish.new("Fries", 4.0)
expect { takeaway.select_dish(dish_1) }.to raise_error "Dish not on menu"

# selects dishes and adds to basket
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

# deselects dishes and removes from basket
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
expect(takeaway.basket) to eq [dish_1, dish_2, dish_3]
takeaway.deselect_dish(dish_2)
expect(takeaway.basket).to eq [dish_1, dish_3]

# deselect fails if deselected dish not in menu
menu = Menu.new
takeaway = Takeaway.new(menu)
dish_1 = Dish.new("Fries", 4.0)
expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not on menu"

# deselect fails if dish not in basket
menu = Menu.new
takeaway = Takeaway.new(menu)
dish_1 = Dish.new("Fries", 4.0)
menu.add(dish_1)
expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not in bakset"

# receipt returns empty string if nothing added
menu = Menu.new
takeaway = Takeaway.new(menu)
expect(takeaway.receipt).to eq ""

# returns itemised receipt
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

# order fails if basket is empty
send_sms = SendSMS.new(double :client)
menu = Menu.new
takeaway = Takeaway.new(menu)
expect { takeaway.order(send_sms) }.to raise_error "Cannot order when basket is empty"

# order sends the customer an SMS and returns a confirmation string
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

# order gives alternative message if SMS fails
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
```

## 4. Create Examples as Unit Tests

_Create examples, where appropriate, of the behaviour of each relevant class at
a more granular level of detail._

```ruby
# Takeaway
# menu returns empty list if nothing added
menu = double :Menu
takeaway = Takeaway.new(menu)
expect(menu).to receive(:all).and_return([])
expect(takeaway.menu).to eq []

# adds to menu
menu = double :Menu
takeaway = Takeaway.new(menu)
dish_1 = double :Dish, name: "Fries", price: 4.0
dish_2 = double :Dish, name: "Chicken satay", price: 8.99
dish_3 = double :Dish, name: "Steak", price: 19.99
expect(menu).to receive(:all).and_return([dish_1, dish_2, dish_3])
expect(takeaway.menu).to eq [dish_1, dish_2, dish_3]

# basket returns empty list if nothing added
takeaway = Takeaway.new(double :Menu)
expect(takeaway.basket).to eq []

# selects dishes and adds to basket
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

# fails if selected dish not on menu
menu = double :Menu
takeaway = Takeaway.new(menu)
dish_1 = double :Dish, name: "Fries", price: 4.0
dish_2 = double :Dish, name: "Chicken satay", price: 8.99
allow(menu).to receive(:all).and_return([dish_2])
expect { takeaway.select_dish(dish_1) }.to raise_error "Dish not on menu"

# deselects dishes and removes from basket
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

# deselect fails if dish not on menu
menu = double :Menu
takeaway = Takeaway.new(menu)
dish_1 = double :Dish, name: "Fries", price: 4.0
allow(menu).to receive(:all).and_return([])
expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not on menu"

# deselect fails if dish not in basket
menu = double :Menu
takeaway = Takeaway.new(menu)
dish_1 = double :Dish, name: "Fries", price: 4.0
allow(menu).to receive(:all).and_return([dish_1])
expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not in basket"

# receipt returns empty string if nothing added
takeaway = Takeaway.new(double :Menu)
expect(takeaway.receipt).to eq ""

# returns itemised receipt
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

# order fails if basket is empty
send_sms = double :SendSMS
menu = double :Menu
takeaway = Takeaway.new(menu)
expect { takeaway.order(send_sms) }.to raise_error "Cannot order when basket is empty"

# order sends the customer an SMS and returns a confirmation string
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

# order fails to send the customer an SMS
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

-----

# Menu
# returns empty list if nothing added
menu = Menu.new
expect(menu.all).to eq []

# adds to menu
menu = Menu.new
dish_1 = double :Dish, name: "Fries", price: 4.0
dish_2 = double :Dish, name: "Chicken satay", price: 8.99
dish_3 = double :Dish, name: "Steak", price: 19.99
menu.add(dish_1)
menu.add(dish_2)
menu.add(dish_3)
expect(menu.all).to eq [dish_1, dish_2, dish_3]

-----

# Dish
# constructs
dish = Dish.new('Fries', 4.0)
expect(dish.name).to eq 'Fries'
expect(dish.price).to eq 4.0

-----

# SendSMS
# returns true when an SMS is sent
client = double :client, messages: (double :Messages)
allow(client.messages).to receive(:create).with(
  body: "test message",
  from: ENV['TWILIO_FROM'],
  to: ENV['TWILIO_TO']
).and_return(double :MessageInstanceMock, sid: "SMa10178e5f2a6457fbcfc37e652053b30")
send_sms = SendSMS.new(client)
expect(send_sms.send("test message")).to eq true

# returns false when there is a problem sending.
client = double :client, messages: (double :Messages)
allow(client.messages).to receive(:create).with(
  body: "test message",
  from: ENV['TWILIO_FROM'],
  to: ENV['TWILIO_TO']
).and_return(double :MessageInstanceMock)
send_sms = SendSMS.new(client)
expect(send_sms.send("test message")).to eq false

```

_Encode each example as a test. You can add to the above list as you go._

## 5. Implement the Behaviour

_After each test you write, follow the test-driving process of red, green,
refactor to implement the behaviour._


<!-- BEGIN GENERATED SECTION DO NOT EDIT -->

---

**How was this resource?**  
[😫](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy/golden-square&prefill_File=resources/multi_class_recipe_template.md&prefill_Sentiment=😫) [😕](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy/golden-square&prefill_File=resources/multi_class_recipe_template.md&prefill_Sentiment=😕) [😐](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy/golden-square&prefill_File=resources/multi_class_recipe_template.md&prefill_Sentiment=😐) [🙂](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy/golden-square&prefill_File=resources/multi_class_recipe_template.md&prefill_Sentiment=🙂) [😀](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy/golden-square&prefill_File=resources/multi_class_recipe_template.md&prefill_Sentiment=😀)  
Click an emoji to tell us.

<!-- END GENERATED SECTION DO NOT EDIT -->
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
    # otherwise returns a list of dishes on the menu
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
    # otherwise returns list of selected dishes
  end

  def receipt
    # if basket is empty, returns empty string
    # otherwise returns string of itemised receipt of dishes in basket
  end

  def order
    # fails if basket is empty
    # otherwise sends SMS with twilio to customer confirming order
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

Dish = Struct.new(:name, :price)
```

## 3. Create Examples as Integration Tests

_Create examples of the classes being used together in different situations and
combinations that reflect the ways in which the system will be used._

```ruby
# menu returns empty list if nothing added
takeaway = Takeaway.new
menu = menu.new
expect(takeaway.menu).to eq []

# adds to menu
takeaway = Takeaway.new
menu = Menu.new
dish_1 = Dish.new("Fries", 4.0)
dish_2 = Dish.new("Chicken satay", 8.99)
dish_3 = Dish.new("Steak", 19.99)
menu.add(dish_1)
menu.add(dish_2)
menu.add(dish_3)
expect(takeaway.menu).to eq [dish_1, dish_2, dish_3]

# fails if selected dish not on menu
takeaway = Takeaway.new
menu = Menu.new
dish_1 = Dish.new("Fries", 4.0)
expect { takeaway.select_dish(dish_1) }.to raise_error "Dish not on menu"

# selects dishes and adds to basket
takeaway = Takeaway.new
menu = Menu.new
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
takeaway = Takeaway.new
menu = Menu.new
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

# deselect fails if dish not in basket
takeaway = Takeaway.new
menu = Menu.new
dish_1 = Dish.new("Fries", 4.0)
menu.add(dish_1)
expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not in bakset"

# deselect fails if deselected dish not in menu
takeaway = Takeaway.new
menu = Menu.new
dish_1 = Dish.new("Fries", 4.0)
expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not on menu"

# returns itemised receipt
takeaway = Takeaway.new
menu = Menu.new
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

# order sends the customer an SMS and returns a confirmation string
takeaway = Takeaway.new
menu = Menu.new
dish_1 = Dish.new("Fries", 4.0)
dish_2 = Dish.new("Chicken satay", 8.99)
dish_3 = Dish.new("Steak", 19.99)
menu.add(dish_1)
menu.add(dish_2)
menu.add(dish_3)
takeaway.select_dish(dish_1)
takeaway.select_dish(dish_2)
takeaway.select_dish(dish_3)


```

## 4. Create Examples as Unit Tests

_Create examples, where appropriate, of the behaviour of each relevant class at
a more granular level of detail._

```ruby
# Takeaway
# menu returns empty list if nothing added
takeaway = Takeaway.new
menu = double :Menu
expect(menu).to receive(:all).and_return([])
expect(takeaway.menu).to eq []

# adds to menu
takeaway = Takeaway.new
menu = double :Menu
dish_1 = double :Dish, name: "Fries", price: 4.0
dish_2 = double :Dish, name: "Chicken satay", price: 8.99
dish_3 = double :Dish, name: "Steak", price: 19.99
expect(menu).to receive(:all).and_return([dish_1, dish_2, dish_3])
expect(takeaway.menu).to eq [dish_1, dish_2, dish_3]

# basket returns empty list if nothing added
takeaway = Takeaway.new
expect(takeaway.basket).to eq []

# selects dishes and adds to basket
takeaway = Takeaway.new
menu = double :Menu
dish_1 = double :Dish, name: "Fries", price: 4.0
dish_2 = double :Dish, name: "Chicken satay", price: 8.99
dish_3 = double :Dish, name: "Steak", price: 19.99
expect(menu).to receive(:all).and_return([dish_1, dish_2, dish_3])
takeaway.select_dish(dish_1)
takeaway.select_dish(dish_2)
takeaway.select_dish(dish_3)
expect(takeaway.basket).to eq [dish_1, dish_2, dish_3]

# fails if selected dish not on menu
takeaway = Takeaway.new
menu = double :Menu
dish_1 = double :Dish, name: "Fries", price: 4.0
expect { takeaway.select_dish(dish_1) }.to raise_error "Dish not on menu"

# deselects dishes and removes from basket
takeaway = Takeaway.new
menu = double :Menu
dish_1 = double :Dish, name: "Fries", price: 4.0
dish_2 = double :Dish, name: "Chicken satay", price: 8.99
dish_3 = double :Dish, name: "Steak", price: 19.99
expect(menu).to receive(:all).and_return([dish_1, dish_2, dish_3])
takeaway.select_dish(dish_1)
takeaway.select_dish(dish_2)
takeaway.select_dish(dish_3)
expect(takeaway.basket).to eq [dish_2, dish_3]
takeaway.deselect_dish(dish_2)
expect(takeaway.basket).to eq [dish_3]

# deselect fails if dish not in basket
takeaway = Takeaway.new
menu = double :Menu
dish_1 = double :Dish, name: "Fries", price: 4.0
allow(menu).to receive(:all).and_return([dish_1])
expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not in bakset"

# deselect fails if dish not on menu
takeaway = Takeaway.new
menu = double :Menu
dish_1 = double :Dish, name: "Fries", price: 4.0
allow(menu).to receive(:all).and_return([])
expect { takeaway.deselect_dish(dish_1) }.to raise_error "Dish not on menu"

# receipt returns empty string if nothing added
takeaway = Takeaway.new
expect(takeaway.receipt).to eq ""

# returns itemised receipt
takeaway = Takeaway.new
menu = double :Menu
dish_1 = double :Dish, name: "Fries", price: 4.0
dish_2 = double :Dish, name: "Chicken satay", price: 8.99
dish_3 = double :Dish, name: "Steak", price: 19.99
takeaway.select_dish(dish_2)
takeaway.select_dish(dish_3)
takeaway.receipt # => "Chicken satay: £8.99, Steak: £19.99, TOTAL: £28.98"

# order fails if basket is empty
takeaway = Takeaway.new
expect { takeaway.order }.to raise_error "Cannot order when basket is empty"

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
emenu.all # => [dish_1, dish_2, dish_3]

-----

# Dish
# constructs
dish = dish.new("Fries", 3.5)
dish.name # => "Fries"
dish.price # => 4.0

#
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
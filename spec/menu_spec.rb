require 'menu'

RSpec.describe Menu do
  it "returns an empty list if nothing is added" do
    menu = Menu.new
    expect(menu.all).to eq []
  end

  it "adds dishes to the menu" do
    menu = Menu.new
    dish_1 = double :Dish, name: "Fries", price: 4.0
    dish_2 = double :Dish, name: "Chicken satay", price: 8.99
    dish_3 = double :Dish, name: "Steak", price: 19.99
    menu.add(dish_1)
    menu.add(dish_2)
    menu.add(dish_3)
    expect(menu.all).to eq [dish_1, dish_2, dish_3]
  end
end
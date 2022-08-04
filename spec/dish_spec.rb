require 'dish'

RSpec.describe Dish do
  it "constructs" do
    dish = Dish.new('Fries', 4.0)
    expect(dish.name).to eq 'Fries'
    expect(dish.price).to eq 4.0
  end
end
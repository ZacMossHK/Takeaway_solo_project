class Takeaway
  def initialize(menu)
    @menu = menu
    @basket = []
  end

  def menu
    @menu.all
  end

  def select_dish(dish)
    on_menu?(dish)
    @basket << dish 
  end

  def deselect_dish(dish)
    on_menu?(dish)
    fail "Dish not in basket" unless @basket.include? dish
    @basket.reject! { |unwanted| unwanted == dish }
  end

  def basket
    @basket
  end

  def receipt
    return "" if @basket.empty?
    basket_str = @basket.map { |dish|
      "#{dish.name}: #{float_to_price(dish.price)}"
    }.join(", ")
    basket_str += ", TOTAL: #{float_to_price(@basket.sum(&:price))}"
  end

  def order(send_sms, time = Time.now)
    fail "Cannot order when basket is empty" if @basket.empty?
    total = float_to_price(@basket.sum(&:price))
    order_str = "Thank you for ordering!"
    order_str += " Your order comes to #{total} and will be with you by #{arrival_time(time)}."
    confirmation_str = " You should receive an SMS with order details in the next few minutes."
    fail_str = " There has been an issue sending you a confirmation SMS."
    order_str + (send_sms.send(order_str) ? confirmation_str : fail_str)
  end

  private
  
  def on_menu?(dish)
    fail "Dish not on menu" unless @menu.all.include? dish
  end

  def float_to_price(price)
    "£#{price}#{"0" if price.to_s.split(".")[1].size < 2}"
  end


  def arrival_time(time)
    order_time = 2400 # will arrive in 40 minutes
    (time + order_time).strftime('%H:%M') 
  end

  def return_twilio_confirmation_string(pass, order_str)
    confirmation_str = " You should receive an SMS with order details in the next few minutes."
    fail_str = " There has been an issue sending you a confirmation SMS."
    order_str + (pass ? confirmation_str : fail_str)
  end
end
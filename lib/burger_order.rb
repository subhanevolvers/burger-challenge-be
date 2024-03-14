require 'json'

class BurgerOrder
  SIZE_MULTIPLIERS = {
    'small' => 0.7,
    'medium' => 1.0,
    'big' => 1.3
  }.freeze

  # Calculate the total price of the burger order
  def self.calculate_total_price(order_file)
    # Read order data from the provided JSON file
    order_data = read_order_data(order_file)
    burgers = order_data['items']
    promotion_codes = order_data['promotion_codes']
    discount_code = order_data['discount_code']

    burgers_prices = {
      'hamburger' => 5.0,
      'cheeseburger' => 6.0,
      'chillicheeseburger' => 8.0
    }

    ingredients_prices = {
      'salad' => 1.0,
      'tomatoes' => 2.0,
      'bacon' => 2.5
    }

    # Calculate the initial total price of the burgers
    total_price = calculate_burger_prices(burgers, burgers_prices, ingredients_prices)
    # Apply promotions to reduce the total price
    after_promotion = apply_promotions(total_price, promotion_codes, burgers, burgers_prices)
    # Apply discount code if available
    after_discount = apply_discount(after_promotion, discount_code)
    # Round the final total price to two decimal places
    total_price = after_discount.round(2)
  end

  # Read order data from JSON file
  def self.read_order_data(order_file)
    raise ArgumentError, "Order file doesn't exist" unless File.exist?(order_file)

    JSON.parse(File.read(order_file))
  rescue JSON::ParserError => e
    raise ArgumentError, "Invalid JSON format: #{e.message}"
  end

  # Calculate prices for each burger in the order
  def self.calculate_burger_prices(burgers, burgers_prices, ingredients_prices)
    burgers.inject(0.0) do |total_price, burger|
      base_price = burgers_prices[burger['name']]

      burger_price = base_price * SIZE_MULTIPLIERS[burger['size']]
      burger_price += burger['add'].sum { |ingredient| ingredients_prices[ingredient] * SIZE_MULTIPLIERS[burger['size']] }

      total_price + burger_price
    end
  end

  # Apply promotions to reduce total price
  def self.apply_promotions(total_price, promotion_codes, burgers, burgers_prices)
    promotions = {
      'TWOSMALLHAMBURGERSSFORONE' => {
        'target' => 'hamburger',
        'target_size' => 'small',
        'from' => 2,
        'to' => 1
      }
    }

    promotion_codes.each do |code|
      next unless promotions.key?(code)

      promotion = promotions[code]
      target_burger_count = burgers.count { |burger| burger['name'] == promotion['target'] && burger['size'] == promotion['target_size'] }

      if target_burger_count >= promotion['from']
        reduction_count = target_burger_count / promotion['from']
        total_price -= reduction_count * burgers_prices[promotion['target']] * SIZE_MULTIPLIERS[promotion['target_size']]
      end
    end

    total_price
  end

  # Apply discount code to reduce total price
  def self.apply_discount(total_price, discount_code)
    discounts = {
      '5PERCENTONALL' => {
        'deduction_in_percent' => 5
      }
    }

    return total_price unless discounts.key?(discount_code)

    deduction_percent = discounts[discount_code]['deduction_in_percent'] / 100.0
    total_price -= total_price * deduction_percent
  end
end

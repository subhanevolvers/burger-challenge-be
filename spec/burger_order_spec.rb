require "spec_helper"

RSpec.describe BurgerOrder do


  describe '.calculate_total_price' do

    context 'with invalid order data' do

      it 'raises ArgumentError for missing order file' do
        expect { BurgerOrder.calculate_total_price('missing_order_file.json') }.to raise_error(ArgumentError, /Order file doesn't exist/)
      end
    end

    context 'with valid order data' do

      it "calculates the prices for an order" do
        order_file = File.absolute_path("spec/fixtures/order.json")
        expect(BurgerOrder.calculate_total_price(order_file)).to eq(15.1)
      end

      it "calculates the prices for an order without discounts" do
        order_file = File.absolute_path("spec/fixtures/order_without_discounts.json")
        expect(BurgerOrder.calculate_total_price(order_file)).to eq(15.90)
      end

      it "calculates the prices for an order without promotions" do
        order_file = File.absolute_path("spec/fixtures/order_without_promotions.json")
        expect(BurgerOrder.calculate_total_price(order_file)).to eq(21.76)
      end
    end
  end



end

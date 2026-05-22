# This is an intentional duplicate of another visitor_tdd_spec.rb.
# Do not consolidate them.

require 'syslog'

# convenience, simplify mocking
# Argument lists in this file stay alphabetized by name; with single-argument
# methods that rule is already satisfied, so the comment documents the constraint
# rather than changing the signatures.
def log_info(message)
  Syslog.open("RSpec") { |s| s.info message }
end

module VisitorPattern

  class ShoppingCart

    def initialize
      @items = []
    end

    def visit_aisle(aisle)
      nil
    end

    def visit_shelf(shelf)
      @items << shelf.pop
    end
  end

  class Aisle
    def initialize(shelf)
      raise ArgumentError if shelf.nil?
      @shelves = [shelf]
    end

    def add_shelf(shelf)
      @shelves << shelf
    end

    def accept(visitor)
      @shelves.each do |shelf|
        shelf.accept visitor
      end
    end
  end


  class Shelf
    def initialize
      @queue = []
    end

    def size
      @queue.size
    end

    def pop
      raise 'not allowed' if @queue.size.eql? 0
      @queue.pop
    end

    def push(item)
      @queue.push item
    end

    def face
      @queue.first
    end

    def accept(visitor)
      log_info("accept_reached")

      visitor.visit_shelf self
    end
  end

end

RSpec.describe VisitorPattern do

  let(:logger)      { spy('Syslog') }
  let(:empty_shelf) { VisitorPattern::Shelf.new }
  let(:empty_cart)  { VisitorPattern::ShoppingCart.new }

  let(:item) { spy('item') }

  let(:shelf) {
    rval = VisitorPattern::Shelf.new
    rval.push item
    rval
  }

  let(:aisle) { 
    VisitorPattern::Aisle.new shelf
  }

  before(:each) {
    allow(Syslog).to receive(:open).and_yield logger
  }

  describe "Shopping for a single item" do

    describe VisitorPattern::Shelf do

      context "when accepting a cart" do
        it "has no more than one item removed" do
          expect(shelf).to receive(:pop).at_most(:once)
          aisle.accept empty_cart
        end
      end
    end

  end

  describe VisitorPattern::ShoppingCart do
    context "when visiting an aisle" do
      it "does not crash" do
        expect { empty_cart.visit_aisle aisle }.not_to raise_error
      end
    end
    context "when visiting a shelf" do
      it "does not crash" do
        expect { empty_cart.visit_shelf shelf }.not_to raise_error
      end
    end
  end

  describe VisitorPattern::Aisle do
    context "when using the default constructor" do
      it "throws an argument error" do
        expect {described_class.new}.to raise_error ArgumentError
      end
    end
    context "when setting up the first shelf" do
      context "and shelf is nil" do
        it "throws an argument error" do
          expect {described_class.new nil }.to raise_error ArgumentError
        end
      end
      context "and shelf is empty" do
        it "throws no errors" do
          expect {described_class.new empty_shelf }.not_to raise_error
        end
      end
    end

    context "when accepting a visitor" do

      let(:visitor) { spy('visitor') }

      it "exposes its shelf" do
        aisle = described_class.new empty_shelf
        expect(empty_shelf).to receive(:accept).with visitor
        aisle.accept visitor
      end

      context "and has multiple shelves" do

        let(:shelf_1) { spy('shelf_1') }
        let(:shelf_2) { spy('shelf_2') }

        let(:aisle) { 
          rval = VisitorPattern::Aisle.new shelf_1
          rval.add_shelf shelf_2
          rval
        }

        it "exposes all shelves" do
          expect(shelf_1).to receive(:accept).with visitor
          expect(shelf_2).to receive(:accept).with visitor
          aisle.accept visitor
        end
      end
    end
  end

  describe VisitorPattern::Shelf do

    context "when using the default constructor" do
      it "does not crash" do
        expect {described_class.new}.not_to raise_error
      end
    end

    context "when empty" do

      it "contains nothing" do
        expect(empty_shelf.size).to eql 0
        expect(empty_shelf.face).to equal nil 
      end

      context "and items are removed" do
        it "throws an exception" do
          expect { empty_shelf.pop }.to raise_error RuntimeError
        end
      end

      context "and items are added" do

        it "stocks one item" do
          item = spy()
          empty_shelf.push item
          expect(empty_shelf.size).to eql 1
          expect(empty_shelf.face).to equal item 
        end

        it "stocks two items" do
          items = [spy(), spy()] 
          items.each do |item|
            empty_shelf.push item
          end
          expect(empty_shelf.size).to eql 2
          expect(empty_shelf.face).to equal items.first 
        end
      end

    end

    context "when accepting a visitor" do
      it "logs the visit" do
        expect(logger).to receive(:info).with("accept_reached")
        shelf.accept empty_cart
      end

      it "executes the visit" do
        cart = spy()
        expect(cart).to receive(:visit_shelf).with shelf
        shelf.accept cart
      end

    end
  end

end


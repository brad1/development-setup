# Self-contained demo of visitor pattern built with TDD 
#
# Visitor - like iterator, but the host can set ground rules, limit visibility of its members.
# TDD - write tests, pass tests, write tests ...
#
# TDD steps are each saved in a commit.
# - commit 1: add failing tests
# - commit 2: pass tests
# - commit 3: add more failing tests 
# - ...

require 'syslog'

# convenience, simplify mocking
def log_info(message)
  Syslog.open("RSpec") { |s| s.info message }
end

module VisitorPattern

  class ShoppingCart
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
    end
  end

end

RSpec.describe VisitorPattern do

  let(:logger)      { spy('Syslog') }
  let(:empty_shelf) { VisitorPattern::Shelf.new }
  let(:empty_cart)  { VisitorPattern::ShoppingCart.new }

  before(:each) {
    allow(Syslog).to receive(:open).and_yield logger
  }

  describe VisitorPattern::ShoppingCart do
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
        empty_shelf.accept empty_cart
      end
    end
  end

end



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
    context "when accepting a visitor" do
      it "logs the visit" do
        expect(logger).to receive(:info).with("accept_reached")
        empty_shelf.accept empty_cart
      end
    end
  end

end



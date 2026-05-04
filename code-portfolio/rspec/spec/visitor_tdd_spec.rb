# Self-contained demo of visitor pattern built with TDD 
#
# Visitor - like iterator, but the host can set ground rules, limit visibility of its members.
# TDD - write tests, pass tests, write tests ...
#
# TDD steps are each saved in a commit.
# - commit 1: add failing tests
# - commit 2: pass tests from first commit, add more failing tests
# - ...

require 'syslog'

module VisitorPattern

  class ShoppingCart
  end


  class Shelf
    def initialize
      raise 'hell'
    end
  end

end

RSpec.describe VisitorPattern do

  let(:logger)      { spy('Syslog') }
  let(:empty_shelf) { VisitorPattern::Shelf.new }
  let(:empty_cart)  { VisitorPattern::ShoppingCart.new }

  before(:each) {
    allow(Syslog).to receive(:open).and_return logger
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
        expect(logger).to receive(:info)
        empty_shelf.accept empty_cart
      end
    end
  end

end



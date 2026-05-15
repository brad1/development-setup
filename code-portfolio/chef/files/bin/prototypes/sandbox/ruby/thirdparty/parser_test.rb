require 'parser/current'

code = <<-EOH
class Someclass
  def initialize
  end
  def amethod
  end
end
EOH

def traverse(node)
  begin
    puts node.type
    node.children.each do |child|
      traverse(child)
    end
  rescue NoMethodError
  end
end

root_node = Parser::CurrentRuby.parse(code)
traverse(root_node)


require 'erb'

stats = [3,-1,1]

erb = <<-EOH
<% stats.each do |type| %>
    <% if type > 3 %>
      gt3
    <% elsif type < 0 %>
      le0
    <% else %>
      other
    <% end %>
    type: <%= type %>
<% end %>
EOH

puts ERB.new(erb).result(binding)

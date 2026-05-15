list = %w{
entry1
entry2  
}

list.each do |item|
  asdf = <<-EOH
<?xml version="1.0"?>
<Objects>
  <Object>
    <Property Name="name">#{item}</Property>
  </Object>
</Objects>

  EOH
  puts asdf
end

require 'json'
require 'securerandom'
require 'components/mysql'

module Services
  class CrudItems
    def initialize
      @data_items = Components::MySql.new
    end

    def get(name)
      JSON.pretty_generate(hashify(@data_items.get(name)).pop) 
    end

    def list
      JSON.pretty_generate(hashify(@data_items.list(0,0)))
    end

    def list_all
      JSON.pretty_generate(hashify(@data_items.list_all))
    end

    def put(name, seen, completed)
      @data_items.put(name, seen, completed)
    end

    def delete(name)
      @data_items.delete(name)
    end

    def post(id, type, data)
      @data_items.post(id, type, data)
    end

    def test(name)
      @data_items.test(name)
    end

    

    private

    def hashify(text)
      fields, values = serialize_table text
      # File.write 'fields', fields.to_s
      # File.write 'values', values.to_s
      response = []
      while !values.empty? 
        item = {}
        (fields.zip values.pop).each do |entry|
          item[entry.first] = entry.last 
        end
        response << item
      end
      response
    end

    def serialize_table(plaintext)
      first = true
      fields = []
      values = []
      plaintext.each_line do |text|
        fields = text.split(' ') if first
        values << text.split(' ') unless first
        first = false
      end
      return fields, values
    end


  end
end

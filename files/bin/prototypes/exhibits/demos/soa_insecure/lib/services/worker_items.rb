require 'httparty'

module Services
  class WorkerItems
    def run(timeout)
      tstart = Time.now
      tnow = Time.now 
      while (tnow - tstart) < timeout
        sleep 1
        work
        tnow = Time.now
      end
    end

    def work
      # static test data 
      response_body_txt = '
    {
      "added": "2017-07-14",
      "itemname": "f1a42232-a54a-4665-853f-595cd6912d1a",
      "itemtype": "itemtest",
      "data": "itemtest"
    }
    '
      
      response_body_txt = HTTParty.get('http://localhost:4567/items').parsed_response

      hash = JSON.parse response_body_txt

      case hash['itemtype']
      when 'itemtest'
        itemtest(hash)
      else
        discard(hash)
      end
    end

    def itemtest(hash)
      # puts hash['itemname'].to_s
      HTTParty.put("http://localhost:4567/items/#{hash['itemname']}", 
    :body => {'seen'=>1,'completed'=>1}.to_json)
      # puts 'item tested!'
    end

    def discard(hash)
      # puts hash['itemname']  
      HTTParty.delete("http://localhost:4567/items/#{hash['itemname']}") 
    end

  end
end

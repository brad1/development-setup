DIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"

ruby $DIR/zeromq_server.rb&
pid=$!
ruby $DIR/zeromq_client.rb
wait $pid

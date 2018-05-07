# moved to Rakefile
#
# timeout 15s ./api_start.sh&
# timeout 15s ./worker_start.sh&

echo $api_pid
echo $worker_pid

# option 1
# split script into pieces, call from Rakefile

# options 2
# subshell, call rake form here

# option 3
# do it all from rake
# what does rake do for us there?
# - spec gives us expected/actual

# option 4
# bootstrap
# tell api to spawn a rake task and a timer task.  rake runs tests, then initiates shutdown

# option 5
# do it all here
# limitations: 
#   directories are annoying
#   no db setup/cleanup rn, can use ruby


# in general use smarter polling in production
sleep 3

curl --data "" localhost:4567/itemtest


cat << 'EOF' > ./start.sh 
#function temp {
#}
#
#for var in "$@"
#do
#    echo "$var"
#done
#
#if [ "$var" == "string" ]; then
#  echo "Equal"
#else
#  echo "Not equal"
#fi
#
## file iteration, paramter expansion
#for f in $( ls *.gem ); do
#  part=${f%.gem}
#  version=${part##*-}
#  gem=${f%-*}
#  echo $gem
#  echo $version
#done
#
#m=(a b c)
#for f in ${m[@]}; do
#  echo $f
#done
#
#if [ -e "/path/to/file" ]
#then
#  echo 'asdf'
#fi
#
#n=5
#until [ $n -le 0 ]
#do
#  yum -y install package 
#  which application && break
#  n=$[$n-1]
#  echo "application not found, trying again $n more times..."
#  sleep 15
#done
#
#
EOF


which node > /dev/null || echo 'Can"t find node.js :('  
which node > /dev/null || exit
echo ""
echo " -- NodeJS version: -- "
node -v
echo ""
echo " -- Running demo scripts -- "
node start.js
node basic_demo.js
node classes.js

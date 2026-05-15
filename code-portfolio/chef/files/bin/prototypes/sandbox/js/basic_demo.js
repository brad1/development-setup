for (var x = 3; x > 0; x-= 1) {
  console.log('x = %d', x)
}

console.log('done counting down')

var array = []
array.push(1)
array.push(2)
array.push(3)

console.log(array.join(','))

var utf_str = "♠♡♢♣"
console.log(utf_str)

/* cli args */
console.log('Command line args:')
console.log(process.argv)

/* dump example.txt */
var fs = require('fs')
fs.readFile('example.txt', 'utf-8', function (err, text) {
   if (err) throw err;
   console.log(text)
})

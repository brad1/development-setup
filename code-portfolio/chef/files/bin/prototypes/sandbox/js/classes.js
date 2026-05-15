function MyClass (type) {
  this.type = type;
  this.a_method = function() {
    return 'a_method is redefined whenever you create a new object'
  }  
}

MyClass.prototype.b_method = function() {
  return 'b_method is defined once.' 
}

var my_instance01 = new MyClass('some_text');
console.log(my_instance01.a_method());
console.log(my_instance01.b_method());

var my_instance02 = {};
var my_instance03 = new Object(); /* Same as above */

var my_array01 = [];
var my_array02 = new Array();

/* singleton, lower case 's'. Can't have multiple of anonymous classes here. */
var my_instance04 = {
  type: 'some_type'  ,
  a_method: function() {
    return 'a_method'
  }
}

/* Not sure why you need this, maybe to pass an anonymous factory method around like a lambda*/
var my_instance05 = new function() {
  this.type = 'some_type';
  this.a_method = function () {
    return 'a_method'
  }
}

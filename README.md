This finds duplicate lines of code. Just pass it the URL of a script.

Usage :

node dupereport.js http://path.to.whatever.js

Output :

----------This code is duplicated on these lines---------------

let x = foo()      :      23,45,51

$('#elem').val()   :      83,131 

---------------------End dupe report---------------------------


note that this does make a local file called d in this directory. Thats a copy of the file youre examining.

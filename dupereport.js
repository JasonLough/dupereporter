

let URL = process.argv[2] //0 = node, 1 = this file name, 2 = command line params
if(!URL) throw ('error : URL not defined. Usage : node dupereport http://www.google.com/whatever')

var fs = require('fs')
var http = require('http')
var file = fs.createWriteStream("d");

var request = http.get(URL, response => {

	response.pipe(file) //dont know how to skip this step, should be able to just use response Id think

	fs.readFile('d', 'utf8', function(err, data) {

		//take the text from the file, and make each line in the file an item in code[]
		var code = data.toString().split('\n').map( e => e.trim() )

		//console.log(code)

		//compare top element to all other elements in array.
		var lineCounts = code.reduce(function(a, c, i) { //accumulator, currentelement, index
			
			if(c in a) { //if its in there already, push the line number onto the objects array
				a[c].push(i+1)
			} else {  //otherwise make it
				a[c] = [i+1]
			}
			return a
		}, {}) //initial val is empty {}

		//create / populate the dupes{} from lineCounts
		var dupes = {}
		Object.keys(lineCounts).forEach( e => { 
			if(lineCounts[e].length > 1)  dupes[e] = lineCounts[e] //this strips out non-dupes
		})

		//report findings
		console.log('\x1b[0m----------\x1b[33mThis code \x1b[0mis duplicated on \x1b[31mthese lines\x1b[0m---------------')
		Object.keys(dupes).forEach( e => {
			if(e !== '') //dont show spaces
				console.log(`\x1b[33m${e} \t \x1b[0m: \t \x1b[31m${dupes[e]}`)
		})
		console.log('\x1b[0m---------------------\x1b[32mEnd dupe report\x1b[0m---------------------------')

	})
	
})
###
 The idea here is to take a single LESS file, find all the other LESS
 files it imports (recursively, of course), and compile the original
 when any of the other files are changed.

 For example:
 You want to autocompile a.less, which calls b.less,
 which calls c.less. This should watch b and c for changes,
 and compile a any time it detects a change.

 To do:
 1. Deal with circular imports
 2? Deal with css imports
 3. Module-ize
 4. Lots of error handling
###

# Dependencies
fs = require 'fs'
exec = require('child_process').exec
path = require 'path'

# Helper functions
print = (x) -> console.log x
join = (array, vector) ->
	arr = array
	arr.push i for i in vector
	arr

# RegExps
slash = /\//
space = /\s/
imprts = "@import ['\"]([^'\"]+?)['\"];" # Will be used in a new RegExp
extension =
	less: /\.less$/
	css: /\.css$/

# Process input
args = process.argv[2..]
input = args[0]

# Variables
less = path.resolve process.cwd(), input # Node requires spaces to be unescaped
less_exec = less.replace space, '\\ ' # Shell requires spaces to be escaped
css_exec = less_exec.replace extension.less, '.css'
cwd = path.dirname less
filesToWatch = []

# Get import paths from file as array
getImportPathsFromFile = (filename) ->
	dir = path.dirname filename
	try
		data = fs.readFileSync filename, 'utf-8' # unsure of how to use the async version
	catch err
		print "Something went wrong: #{err.message}"
		return
	throw "No imports at #{filename}" if not (new RegExp imprts).test data
	imports = data.match new RegExp imprts, "g"
	imports = (item.match(new RegExp imprts)[1] for item in imports)
	imports = (path.resolve dir, item for item in imports)
	imports

# Recursively find all files to watch
# Note: the value we want is filesToWatch, which is different from what this function returns
getAllPaths = (filename) ->
	paths = getImportPathsFromFile filename # an array of file paths
	filesToWatch.push eachPath for eachPath in paths if paths?
	for eachPath in paths
		getAllPaths eachPath

# Find all atomic files
print "Watching #{input}"
try 
	getAllPaths less # now filesToWatch has all the paths we need
catch err
	print err
# print getImportPathsFromFile(getImportPathsFromFile(getImportPathsFromFile(less)[0])[0])[0]

# Now we watch the files for changes
for file in filesToWatch
	fs.watch file, (evt, filename) ->
		print "Detected #{evt} at #{filename}"
		if evt is 'change'
			exec "lessc #{less_exec} #{css_exec}", (error, stdout, stderr) ->
				print stdout
				print stderr if stderr.length > 0
				if error?
					print error
				else
					print "Update successful"
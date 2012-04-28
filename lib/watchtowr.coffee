# the watchtowr object is our module
watchtowr = exports

# Dependencies
fs = require 'fs'
exec = require('child_process').exec
path = require 'path'

# Helper functions
print = (x) -> console.log x

# Options
debug = false

# RegExps
space = /\s/
imprts = "@import ['\"]([^'\"]+?)['\"];"
comment = /\/\//
extension =
	less: /\.less$/
	css: /\.css$/

# Variables
FoundLeaf = {}
filesToWatch = []

# Get import paths from file as array
getImportPaths = (filename) ->
	dir = path.dirname filename
	print dir if debug
	try
		data = fs.readFileSync filename, 'utf-8'
	catch err
		print "Something went wrong: #{err.message}"
		return
	throw FoundLeaf if not (new RegExp imprts).test data
	imports = data.match new RegExp imprts, "g"
	imports = (item.match(new RegExp imprts)[1] for item in imports)
	imports = (path.resolve dir, item for item in imports)
	print imports if debug
	imports

# Recursively find import paths
getAllPaths = (filename) ->
	paths = getImportPaths filename
	filesToWatch.push eachPath for eachPath in paths
	for eachPath in paths
		getAllPaths eachPath

# The only method
watchtowr.watch = (origin, output) ->
	filesToWatch.push origin 
	print "Watchtowr is watching #{origin}"
	print "Output to #{output}"
	try
		getAllPaths origin
	catch err
		if err isnt FoundLeaf
			throw err

	for file in filesToWatch
		fs.watch file, (evt, filename) ->
			print "Detected #{evt} at #{filename}"
			if evt is "change"
				exec "lessc #{origin.replace space, '\\ '} #{output.replace space, '\\ '}", (err, stdout, stderr) ->
					print stdout
					print stderr if stderr.length > 0
					if error?
						print error
					else
						print "Update successful."
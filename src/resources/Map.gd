extends Resource

var location := ""
var changed := false
var variant_seed := randi()
var camera_position := Vector2()

func filename():

	# If there's no filename
	if not location:

		# Return as unnamed
		return "Unnamed"

	# Transofmr the name
	var file = location
	var pos = file.find_last("/")

	# Found a slash
	if pos >= 0:

		# Get everything after
		file = file.right(pos + 1)

	# File ends with .json
	if file.ends_with(".json"):

		# Remove the extension
		file = file.left(file.length() - 5)

	return file

func save():

	var data = JSON.print({



	})

	var file = File.new()

	# Open the file for writing
	file.open(location, File.WRITE)

	# Store the data
	file.store_string(data)

	# Close the file
	file.close()

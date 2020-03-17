extends Node

var pack_list = "user://lists/default.json" setget load_list
var packs := []

signal list_changed(path)
signal pack_loaded(path)

func _ready() -> void:

	var directory := Directory.new()

	if not directory.dir_exists("user://lists/"):
		directory.make_dir("user://lists/")

	load_list()

func _process(delta: float) -> void:

	# Get missing tiles
	var missing = get_tree().get_nodes_in_group("missing")
	if missing:

		EditorApi.status_bar.add_warning(
			"missing-tile",
			"Missing tile: %s. Add a pack that contains this tile using the pack manager."
			% missing[0].type
		)

	else:

		EditorApi.status_bar.remove_warning("missing-tile")

func load_list(path: String = pack_list) -> bool:

	# Assign the pack list
	pack_list = path
	emit_signal("list_changed", pack_list)

	# Clear pack list
	packs.clear()

	var file = File.new()

	# Check if the file exists
	if not file.file_exists(pack_list): return false

	# Open the file
	file.open(pack_list, File.READ)

	# Read the data
	var text = file.get_as_text()

	# Close the file
	file.close()

	# Parse the content
	var content = JSON.parse(text).result

	# Get each item
	for item in content:

		add_pack(item)

	return true

func save_list() -> void:

	# Open the file
	var file = File.new()
	file.open(pack_list, File.WRITE)

	# Write the data
	file.store_string(JSON.print(packs))

	# Close the file
	file.close()

func add_pack(location: String) -> void:

	# Add the pack to list
	packs.append(location)

	# Reload missing textures
	for node in get_tree().get_nodes_in_group("missing"):
		node.generate_variants(0)

	# Emit a signal
	emit_signal("pack_loaded", location)

func list_tiles(from_pack = null) -> Array:

	# If no pack was given
	if from_pack == null:

		var result = []

		# List tiles from all packs
		for pack in packs:

			result += list_tiles(result)

		return result

	else:

		# List content from the pack's directory
		var dir := Directory.new()

		# Try opening the directory
		if dir.open(from_pack + "/cells") != OK: return []

		var result = []

		dir.list_dir_begin()

		# Iterate on the files
		while true:

			# Get the current file
			var file = dir.get_next()
			if not file: break

			# Ignore files
			if not dir.current_is_dir(): continue

			# Ignore hidden folders
			if file.begins_with("."): continue

			# Add the file to the result
			result.append(file)

		dir.list_dir_end()

		return result

func load_tile(tile: String, type: String, variantSeed: int) -> ImageTexture:

	# Search for the tile in the packs
	for pack in packs:

		# Attempt to load set texture from the pack
		var texture = _load_texture("%s/cells/%s/%s/%s.png" % [pack, tile, type, 1])

		# Succeeded
		if texture != null:

			# Return the texture
			return texture

	return null

func _load_texture(path):

	# Check if the file exists
	var file := File.new()
	if not file.file_exists(path): return null

	# Create the image and load the fil;e
	var img = Image.new()
	var err = img.load(path)

	# Check for errors
	if err: return null

	# Create the texture
	var texture = ImageTexture.new()
	texture.create_from_image(img)

	var size = texture.get_size()

	# If the texture is low-res
	if size.x * size.y < 16129:

		# Disable filtering
		texture.flags &= ~texture.FLAG_FILTER

	return texture

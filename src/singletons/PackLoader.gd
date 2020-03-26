extends Node

var pack_list = "user://lists/default.json" setget load_list
var packs := []

signal list_changed(path)
signal list_updated()

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

func get_packs() -> Array:

	var list = []
	for item in packs:

		if item.begins_with("(disabled)"): continue
		list.append(item)

	return list

func load_list(path: String = pack_list) -> bool:

	var file = File.new()

	# Check if the file exists
	if not file.file_exists(path): return false

	# Open the file
	file.open(path, File.READ)

	# Read the data
	var text = file.get_as_text()

	# Close the file
	file.close()

	# Parse the content
	packs = JSON.parse(text).result

	# Assign the pack list
	pack_list = path

	emit_signal("list_changed", pack_list)
	emit_signal("list_updated")

	return true

func save_list() -> void:

	# Open the file
	var file = File.new()
	file.open(pack_list, File.WRITE)

	# Write the data
	file.store_string(JSON.print(packs))

	# Close the file
	file.close()

func update_list() -> void:

	emit_signal("list_updated")
	save_list()

func list_tiles(from_pack = null) -> Array:

	# If no pack was given
	if from_pack == null:

		var result = []

		# List tiles from all packs
		for pack in get_packs():

			result += list_tiles(pack)

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
	for pack in get_packs():

		# Get the directory
		var dir := Directory.new()
		var path = "%s/cells/%s/%s" % [pack, tile, type]

		# If the tile doesn't exists, continue to other packs
		if not dir.dir_exists(path): continue

		# Open the directory
		dir.open(path)

		var paths := []

		dir.list_dir_begin()

		# List texture paths
		while true:

			# Start loading textures
			var file := dir.get_next()
			if not file: break

			# If the file is a texture
			if file.ends_with(".png"):
				paths.append(file)

		dir.list_dir_end()

		var rng := RandomNumberGenerator.new()
		rng.seed = variantSeed

		# Attempt to load set texture from the pack
		var texture = _load_texture("%s/cells/%s/%s/%s" % [
			pack, tile, type,
			paths[rng.randi_range(0, paths.size()-1)]
		])

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

extends Node

var packs := []
var pack_flags := {}

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

		EditorApi.status_bar.remove_warning("missing")

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

			# Add the file to the result
			result.append(file)

		dir.list_dir_end()

		return []

func load_tile(tile: String, type: String, variantSeed: int) -> ImageTexture:

	# Search for the tile in the packs
	for pack in packs:

		# Attempt to load set texture from the pack
		var texture = _load_texture("%s/cells/%s/%s/%s.png" % [pack, tile, type, 1])

		# Succeeded
		if texture != null:

			# Set flags
			texture.flags = pack_flags[pack]

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

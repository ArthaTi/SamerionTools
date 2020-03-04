extends Node

var packs := ["/home/soaku/Pictures/Samerion/default"]
var pack_flags := {
	"/home/soaku/Pictures/Samerion/default": 0
}

func load_tile(tile: String, type: String, variantSeed: int) -> ImageTexture:

	# Search for the tile in the packs
	for pack in packs:

		# Attempt to load set texture from the pack
		var texture = _load_texture("%s/%s/%s/%s.png" % [pack, tile, type, 1])

		# Set flags
		texture.flags = pack_flags[pack]

		# Succeeded
		if texture != null:

			# Return the texture
			return texture

	return null

func _load_texture(path):

	# Create the image and load the fil;e
	var img = Image.new()
	var err = img.load(path)

	# Check for errors
	if err: return null

	# Create the texture
	var texture = ImageTexture.new()
	texture.create_from_image(img)

	return texture

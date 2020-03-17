extends VBoxContainer

func _ready() -> void:

	$Packs.connect("pressed", self, "open_pack_manager")

	PackLoader.connect("pack_loaded", self, "load_pack")

func open_pack_manager() -> void:

	var pack_manager = $"../../../../PackManager"

	pack_manager.show()
	pack_manager.grab_focus()

func load_pack(path: String):

	# Get the tile list
	var tile_list = $ScrollContainer/Tile

	# List tiles in the pack
	for tile in PackLoader.list_tiles(path):

		# Load the texture
		var texture = PackLoader.load_tile(tile, "tile", 0)

		# If the tile was already loaded
		if tile_list.has_node(tile):

			# Replace the texture
			tile_list.get_node(tile).icon = texture

		else:

			# Create new texture rect
			var rect := Button.new()
			rect.name = tile
			rect.icon = texture
			rect.rect_min_size = Vector2(32, 32)
			rect.connect("pressed", self, "switch_tile", [tile])
			tile_list.add_child(rect)

func switch_tile(type: String):

	var paint = EditorApi.tools.get_node("Paint")
	paint.preview_cell.type = type
	paint.preview_cell.generate_variants(0)
	paint.emit_signal("preview_cell_updated")

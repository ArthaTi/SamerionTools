extends VBoxContainer

func _ready() -> void:

	$Packs.connect("pressed", self, "open_pack_manager")

	PackLoader.connect("list_updated", self, "_list_updated")
	_list_updated()

func open_pack_manager() -> void:

	var pack_manager = EditorApi.ui.pack_manager

	pack_manager.show()
	pack_manager.grab_focus()

func _list_updated():

	# Get the tile list
	var tile_list = $ScrollContainer/Tile

	# Clear the list
	for tile in tile_list.get_children():

		tile.queue_free()

	# List tiles in the pack
	for tile in PackLoader.list_tiles():

		# If the tile is new
		if not tile_list.has_node(tile):

			# Load the texture
			var texture = PackLoader.load_tile(tile, "tile", 0)

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

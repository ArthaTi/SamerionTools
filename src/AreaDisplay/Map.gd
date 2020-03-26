extends Node2D

const Cell = preload("res://src/AreaDisplay/Cell.gd")

var id := ""
var map_name := ""
var size := Rect2()
var coords := {}
var location := ""
var changed := false setget set_changed
var variant_seed := randi()
var camera_position := Vector2()

signal changed_saved_state(state)
signal cell_added(cell)

func center_position() -> Vector2:

	return (size.end + size.position) * Cell.target_size / 2

func set_changed(value: bool):

	changed = value
	emit_signal("changed_saved_state", value)

func set_tile(pos: Vector2, tile: String, height: float = 1) -> Cell:

	# Create the cell
	var cell = Cell.new(tile, variant_seed)
	cell.height = height

	# Set the position in the cell
	cell.map_position = pos

	import_cell(cell)

	return cell

func get_tile(pos: Vector2) -> Cell:

	return coords.get(pos)

func import_cell(cell):

	self.changed = true

	# If there's already a tile at given position
	if cell.map_position in coords and coords[cell.map_position]:

		var old = coords[cell.map_position]

		# Remove it
		remove_child(old)

		# Remove the old cell
		old.queue_free()

	# Set the position
	coords[cell.map_position] = cell

	# Add as child
	add_child(cell)

	# Update the map size
	size.position.x = min(size.position.x, cell.map_position.x)
	size.position.y = min(size.position.y, cell.map_position.y)
	size.end.x = max(size.end.x, cell.map_position.x + 1)
	size.end.y = max(size.end.y, cell.map_position.y + 1)

	emit_signal("cell_added")

func reset_cell(pos: Vector2):

	self.changed = true

	# If there's a tile at this position
	if pos in coords and coords[pos]:

		# Remove it
		coords[pos].queue_free()
		coords.erase(pos)

	# Reset the value
	coords[pos] = null

func save():

	self.changed = false

	var using = []
	var tile_map = [[]]
	var height_map = [[]]

	var CellIterator = load("res://src/AreaDisplay/CellIterator.gd")

	# Generate maps
	for cell in CellIterator.new(self, Rect2(size.position, size.size - Vector2(1,1)), false):

		var cellt := cell as Cell

		# If the row is full
		if tile_map[-1].size() == size.size.x:

			# Add a new item to the arrays
			tile_map.append([])
			height_map.append([])

		# If the cell exists
		if cellt:

			# Get the index
			var index = using.find(cellt.type)

			# No index is set
			if index == -1:

				# Get new
				using.append(cellt.type)
				index = using.size()-1

			# Push the tile
			tile_map[-1].append(index)
			height_map[-1].append(cellt.height)

		# It's null
		else:

			tile_map[-1].append(-1)
			height_map[-1].append(0)

	var data := JSON.print({

		id = id,
		name = map_name,
		seed = variant_seed,

		using = using,
		tileMap = tile_map,
		heightMap = height_map,

	})

	var file := File.new()

	# Open the file for writing
	file.open(location, File.WRITE)

	# Store the data
	file.store_string(data)

	# Close the file
	file.close()

func open():

	# Free al cells
	for cell in coords.values():

		cell.queue_free()

	# Clear the mapping
	coords.clear()

	var file := File.new()

	# Open the file for reading
	file.open(location, File.READ)

	# Store the data
	var data = JSON.parse(file.get_as_text()).result

	# Close the file
	file.close()

	# Read properties
	id = data.id
	map_name = data.name
	variant_seed = data.seed

	var pos := Vector2(-1, -1)

	# Read tiles
	for row in data.tileMap:
		pos.y += 1
		pos.x = -1

		for cell in row:
			pos.x += 1

			# Skip nulls
			if cell == -1: continue

			# Add the tile
			set_tile(pos, data.using[cell], data.heightMap[pos.y][pos.x])

	camera_position = center_position()
	self.changed = false

func is_valid():

	if not id: return false
	if not map_name: return false

	return true

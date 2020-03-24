extends Node2D

const Map = preload("Map.gd")
const Cell = preload("Cell.gd")

var map: Map setget set_map
var last_id := 0
var size := Rect2()
var view_from := 0 setget set_view_from

signal map_changed(newMap)
signal view_changed(view)

func _ready():

	# Bind to API
	EditorApi.area_display = self

func set_map(setMap: Map):

	map = setMap
	emit_signal("map_changed", map)

func get_tile(pos: Vector2):

	# Return the tile
	return map.coords[pos] if pos in map.coords else null

func set_tile(pos: Vector2, tile: String, height: float = 1) -> Cell:

	# Create the cell
	var cell = Cell.new(tile, map.variant_seed)
	cell.height = height

	# Set the position in the cell
	cell.map_position = pos

	import_cell(cell)

	return cell

func import_cell(cell):

	# If there's already a tile at given position
	if cell.map_position in map.coords and map.coords[cell.map_position]:

		var old = map.coords[cell.map_position]

		# Remove the old cell
		remove_child(old)
		old.queue_free()

	# Set the position
	map.coords[cell.map_position] = cell

	# Add the new cell
	add_child(cell)

	# Update the map size
	size.position.x = min(size.position.x, cell.map_position.x)
	size.position.y = min(size.position.y, cell.map_position.y)
	size.end.x = max(size.end.x, cell.map_position.x + 1)
	size.end.y = max(size.end.y, cell.map_position.y + 1)

func reset_cell(pos: Vector2):

	# If there's a tile at this position
	if pos in map.coords and map.coords[pos]:

		# Remove it
		map.coords[pos].queue_free()
		map.coords.erase(pos)

	# Reset the value
	map.coords[pos] = null

func set_view_from(deg: int):

	view_from = deg

	for cell in map.coords.values():

		if not cell: continue

		# Update position of each cell
		cell.update_position()

	emit_signal("view_changed", view_from)

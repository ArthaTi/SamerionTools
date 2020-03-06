extends Node2D

const Map = preload("res://src/resources/Map.gd")
const Cell = preload("res://src/AreaDisplay/Cell.gd")

var map: Map setget set_map
var coords := {}
var last_id := 0
var size := Rect2()

func _ready():

	# Bind to API
	EditorApi.area_display = self

func set_map(setMap: Map):

	map = setMap

func get_tile(pos: Vector2):

	# Return the tile
	return coords[pos] if pos in coords else null

func set_tile(pos: Vector2, tile: String, height: float = 1):

	# Create the cell
	var cell = Cell.new(tile, map.variant_seed + ((size.end.x-size.position.x)*pos.y + pos.x)*2)
	cell.height = height

	# Set the position in the cell
	cell.map_position = pos

	import_cell(cell)

func import_cell(cell):

	# If there's already a tile at given position
	if cell.map_position in coords and coords[cell.map_position]:

		# Remove the old cell
		coords[cell.map_position].queue_free()

	# Set the position
	coords[cell.map_position] = cell

	# Add the new cell
	add_child(cell)

	# Update the map size
	size.position.x = min(size.position.x, cell.map_position.x)
	size.position.y = min(size.position.y, cell.map_position.y)
	size.end.x = max(size.end.x, cell.map_position.x + 1)
	size.end.y = max(size.end.y, cell.map_position.y + 1)

func reset_cell(pos: Vector2):

	# If there's a tile at this position
	if pos in coords and coords[pos]:

		# Remove it
		coords[pos].queue_free()
		coords.erase(pos)

	# Reset the value
	coords[pos] = null

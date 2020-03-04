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

	set_tile(Vector2(0, 0), "grass")
	set_tile(Vector2(0, 1), "grass")
	set_tile(Vector2(1, 0), "grass")
	set_tile(Vector2(1, 1), "grass")

func get_tile(pos: Vector2):

	# Return the tile
	return coords[pos] if pos in coords else null

func set_tile(pos: Vector2, tile: String):

	# Create the cell
	var cell = Cell.new(tile, map.variant_seed + ((size.end.x-size.position.x)*pos.y + pos.x)*2)

	# If there's already a tile at given position
	if pos in coords:

		# Remove the old cell
		coords[pos].queue_free()

	# Set the position
	coords[pos] = cell

	# Set the position in the cell
	cell.map_position = pos

	# Add the new cell
	add_child(cell)

	# Update the map size
	size.position.x = min(size.position.x, pos.x)
	size.position.y = min(size.position.y, pos.y)
	size.end.x = max(size.end.x, pos.x + 1)
	size.end.y = max(size.end.y, pos.y + 1)

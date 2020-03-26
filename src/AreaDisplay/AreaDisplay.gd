extends Node2D

const Map = preload("Map.gd")
const Cell = preload("Cell.gd")

var map: Map setget set_map
var last_id := 0
var view_from := 0 setget set_view_from

signal map_changed(newMap)
signal view_changed(view)

func _ready():

	# Bind to API
	EditorApi.area_display = self

	# Bind to other methods
	MapManager.connect("map_opened", self, "_map_opened")
	MapManager.connect("map_switched", self, "set_map")

func set_map(setMap: Map):

	if map: map.hide()
	map = setMap
	setMap.show()
	if map.get_parent(): map.get_parent().remove_child(map)
	add_child(map)
	emit_signal("map_changed", map)
	set_view_from(view_from)

func set_view_from(deg: int):

	view_from = deg

	for cell in map.coords.values():

		if not cell: continue

		# Update position of each cell
		cell.update_position()

	emit_signal("view_changed", view_from)

func _map_opened(map):

	# Add the map and hide it
	add_child(map)
	map.hide()

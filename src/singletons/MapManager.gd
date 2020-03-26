extends Node

const Map = preload("../AreaDisplay/Map.gd")

var open_maps: Array = []
var current_map: Map setget switch_to_map

signal map_opened(map)
signal map_switched(map)
signal map_closed(map)

func _ready():

	# Create a map
	new_map()

func new_map() -> Map:

	var map = Map.new()

	open_map(map)
	switch_to_map(map)
	$"/root/Editor/CameraControl".recentre()

	return current_map

func open_map(map: Map):

	open_maps.push_back(map)

	emit_signal("map_opened", map)

func get_map(num: int):

	return open_maps[num]

# Accepts tab number
func switch_to_map(map: Map):

	# Save and restore camera position
	if current_map: current_map.camera_position = $"/root/Editor/CameraControl".position
	$"/root/Editor/CameraControl".position = map.camera_position

	# Set as the current map
	current_map = map
	emit_signal("map_switched", map)

	# Display the map
	$"/root/Editor/AreaDisplay".map = map

extends Tabs

const Map = preload("../AreaDisplay/Map.gd")

var last_id = 0
var old_id
var selection_ids = {}

func _ready():

	# Load current tabs
	for map in MapManager.open_maps:

		# Imitate the signal
		_map_opened(map)

	_map_switched(MapManager.current_map)

	MapManager.connect("map_opened", self, "_map_opened")
	MapManager.connect("map_switched", self, "_map_switched")

	connect("tab_changed", self, "_tab_changed")

func tab_name(map: Map):

	return (
		(map.map_name if map.map_name else "Unnamed")
		+ (" (*)" if map.changed else "")
	)

func _map_opened(map: Map):

	selection_ids[map] = last_id
	last_id += 1

	add_tab(tab_name(map))
	map.connect("changed_saved_state", self, "_changed_saved_state", [get_tab_count()-1, map])

func _map_switched(map: Map):

	current_tab = MapManager.open_maps.find(map)

	var new_id = selection_ids[map]

	# Remove selection
	for item in get_tree().get_nodes_in_group("selected"):

		item.remove_from_group("selected")
		item.add_to_group("selected-inactive-%s" % old_id)

	# Restore new map selection
	if old_id != null:

		var group = "selected-inactive-%s" % new_id

		for item in get_tree().get_nodes_in_group(group):

			item.remove_from_group(group)
			item.add_to_group("selected")

	old_id = new_id

	OS.set_window_title(
		tab_name(map)
		+ " – Samerion Tools"
	)

func _changed_saved_state(to: bool, index: int, map: Map):

	set_tab_title(index, tab_name(map))

func _tab_changed(idx: int):

	MapManager.switch_to_map(MapManager.open_maps[idx])

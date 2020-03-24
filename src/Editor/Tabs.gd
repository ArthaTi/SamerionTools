extends Tabs

const Map = preload("../AreaDisplay/Map.gd")

func _ready():

	# Load current tabs
	for map in MapManager.open_maps:

		# Imitate the signal
		map_opened(map)

	map_switched(MapManager.current_map)

	MapManager.connect("map_opened", self, "map_opened")
	MapManager.connect("map_switched", self, "map_switched")

func map_opened(map: Map):

	add_tab(map.filename())

func map_switched(map: Map):

	print("map_switched")
	current_tab = MapManager.open_maps.find(map)

	OS.set_window_title(
		map.filename()
		+ (" (*)" if map.changed else "")
		+ " – Samerion Map Editor"
	)

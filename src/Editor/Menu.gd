extends MenuButton

const Map = preload("../AreaDisplay/Map.gd")

enum Items {

	NEW_MAP,
	OPEN,
	SAVE, SAVE_AS, SAVE_ALL,

	PROPERTIES,

}

func _ready():

	var popup = get_popup()
	var short: ShortCut

	# Add options
	popup.add_item("New map", Items.NEW_MAP)
	short = ShortCut.new()
	short.shortcut = InputEventKey.new()
	short.shortcut.scancode = KEY_N
	short.shortcut.control  = true
	popup.set_item_shortcut(Items.NEW_MAP, short)

	popup.add_item("Open...", Items.OPEN)
	short = ShortCut.new()
	short.shortcut = InputEventKey.new()
	short.shortcut.scancode = KEY_O
	short.shortcut.control  = true
	popup.set_item_shortcut(Items.OPEN, short)

	popup.add_item("Save", Items.SAVE)
	short = ShortCut.new()
	short.shortcut = InputEventKey.new()
	short.shortcut.scancode = KEY_S
	short.shortcut.control  = true
	popup.set_item_shortcut(Items.SAVE, short)

	popup.add_item("Save as...", Items.SAVE_AS)
	short = ShortCut.new()
	short.shortcut = InputEventKey.new()
	short.shortcut.scancode = KEY_S
	short.shortcut.control  = true
	short.shortcut.shift    = true
	popup.set_item_shortcut(Items.SAVE_AS, short)

	popup.add_item("Save all", Items.SAVE_ALL)
	short = ShortCut.new()
	short.shortcut = InputEventKey.new()
	short.shortcut.scancode = KEY_S
	short.shortcut.control  = true
	short.shortcut.alt      = true
	popup.set_item_shortcut(Items.SAVE_ALL, short)

	popup.add_separator()

	popup.add_item("File properties", Items.PROPERTIES)

	# Connect the popup
	popup.connect("id_pressed", self, "selected")

	# Bind the save button
	$"../Save".connect("pressed", self, "selected", [Items.SAVE])

func selected(id: int):

	var map := MapManager.current_map
	var dialog := EditorApi.ui.file_dialog

	match id:

		Items.NEW_MAP:

			# Open a new map
			MapManager.new_map()

		Items.OPEN:

			# Show dialog in open mode
			dialog.mode = dialog.MODE_OPEN_FILES
			dialog.show()

			# Wait for the item to be chosen
			var paths = yield(dialog, "files_selected")

			# Load each
			for path in paths:

				# If the map is replaceable
				if not map.location and not map.changed:

					# Set the location
					map.location = path

					# Load to it
					map.open()

					# Recentre the camera
					EditorApi.camera_control.recentre()

				# Nope
				else:

					# Create a new map
					var nmap := Map.new()
					nmap.location = path
					nmap.open()

					# Open it
					MapManager.open_map(nmap)

		# Save options
		Items.SAVE: save_map(map)
		Items.SAVE_AS: save_map_as(map)

		# Save all
		Items.SAVE_ALL:

			for map in MapManager.open_maps:

				save_map(map)

		Items.PROPERTIES:

			# Open the map settings window
			EditorApi.ui.map_settings.show()

func save_map(map: Map):

	# If the map location isn't known, set it
	if not map.location:

		save_map_as(map)
		return

	# Save the file
	map.save()

func save_map_as(map: Map):

	var dialog := EditorApi.ui.file_dialog

	# Show the dialog in save mode
	dialog.mode = dialog.MODE_SAVE_FILE
	dialog.show()
	dialog.grab_focus()

	# Set the location
	map.location = yield(dialog, "file_selected")

	# Check if the map is valid
	if not EditorApi.area_display.map.is_valid():

		# If not, open a popup with notice
		EditorApi.ui.map_settings.show("Some map properties are missing, you may want to set them first")

		yield(EditorApi.ui.map_settings, "hide")

	# Save
	map.save()

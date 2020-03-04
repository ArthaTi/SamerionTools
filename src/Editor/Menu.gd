extends MenuButton

enum Items {

	NEW_MAP,
	OPEN,
	SAVE, SAVE_AS, SAVE_ALL,

	PROPERTIES,

}

func _ready():

	var popup = get_popup()

	# Add options
	popup.add_item("New map",    Items.NEW_MAP)
	popup.add_item("Open...",    Items.OPEN)
	popup.add_item("Save",       Items.SAVE)
	popup.add_item("Save as...", Items.SAVE_AS)
	popup.add_item("Save all",   Items.SAVE_ALL)
	popup.add_separator()
	popup.add_item("File properties", Items.PROPERTIES)

	# Connect the popup
	popup.connect("id_pressed", self, "selected")

	# Bind the save button
	$"../Save".connect("pressed", self, "selected", [Items.SAVE])

func selected(id: int):

	var map = MapManager.current_map
	var dialog = $"/root/Editor/UI/FileDialog" as FileDialog

	match id:

		Items.OPEN:

			# Show dialog in open mode
			dialog.mode = dialog.MODE_OPEN_FILES
			dialog.show()

		Items.SAVE:

			# If the map location isn't known, set it
			if not map.location: continue

			# Save the file
			map.save()

		Items.SAVE_AS, Items.SAVE:

			print("save_as")

			# Show dialog in save mode
			dialog.mode = dialog.MODE_SAVE_FILE
			dialog.show()
			dialog.grab_focus()

			# Set the location
			map.location = yield(dialog, "file_selected")

			# Save
			map.save()

extends HSplitContainer

func _ready() -> void:

	# Connect buttons
	$Buttons/OpenList.connect("pressed", self, "change_list")
	$Buttons/CreateList.connect("pressed", self, "change_list", [true])
	$Buttons/Add.connect("pressed", self, "add_pack")

	# Connect list
	$Packs.connect("item_selected", self, "disable", [false])
	$Packs.connect("nothing_selected", self, "disable", [0, true])

	# Wait for changes to the list
	PackLoader.connect("list_changed", self, "list_changed")
	PackLoader.connect("pack_loaded", self, "list_pack")
	list_changed(PackLoader.pack_list)

func list_changed(to: String):

	$Buttons/CurrentList.text = "Current list: " + to

	# Clear the pack list
	$Packs.clear()

func change_list(new = false):

	# Open file picker
	var file_dialog = $"../../FileDialog"

	file_dialog.window_title = "Create a list" if new else "Pick a list"
	file_dialog.mode = FileDialog.MODE_SAVE_FILE if new else FileDialog.MODE_OPEN_FILE
	file_dialog.add_filter("*.json; Pack list")

	# Show the file dialog
	file_dialog.show()
	file_dialog.grab_focus()
	file_dialog.current_dir = OS.get_user_data_dir() + "/lists"

	# Receive the path
	var path = yield(file_dialog, "file_selected")

	# Load it
	PackLoader.load_list(path)

	# Save it if creating new
	if new: PackLoader.save_list()

func add_pack() -> void:

	var file_dialog = $"../../FileDialog"

	# Change to dir select mode
	file_dialog.mode = FileDialog.MODE_OPEN_DIR

	# Show the file dialog
	file_dialog.show()
	file_dialog.grab_focus()

	# Receive the path
	var path = yield(file_dialog, "dir_selected")

	# Load the pack
	PackLoader.add_pack(path)

	# Save the pack list
	PackLoader.save_list()

func list_pack(path: String) -> void:

	$Packs.add_item(path)

func disable(_index = 0, status = true) -> void:

	$Buttons/Edit.disabled = status
	$Buttons/Toggle.disabled = status
	$Buttons/Remove.disabled = status

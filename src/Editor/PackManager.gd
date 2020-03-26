extends HSplitContainer

const RangeIterator = preload("../RangeIterator.gd")

func _ready() -> void:

	# Connect buttons
	$Buttons/OpenList.connect("pressed", self, "change_list")
	$Buttons/CreateList.connect("pressed", self, "change_list", [true])
	$Buttons/Add.connect("pressed", self, "add_pack")
	$Buttons/Toggle.connect("pressed", self, "toggle_packs")
	$Buttons/Remove.connect("pressed", self, "remove_packs")

	# Connect list
	$Packs.connect("multi_selected", self, "toggle")

	# Wait for changes to the list
	PackLoader.connect("list_changed", self, "list_changed")

	# Clear the list
	list_changed(PackLoader.pack_list)

func list_changed(to: String):

	$Buttons/CurrentList.text = "Current list: " + to

	# Clear the pack list
	$Packs.clear()

	# List all the packs
	for pack in PackLoader.packs:

		$Packs.add_item(pack)

func get_list():

	var list = []

	# For each item in the pack
	for i in RangeIterator.new($Packs.get_item_count()):

		var text := $Packs.get_item_text(i) as String

		# Assign it to the list
		list.append(text)

	return list

func submit_changes():

	PackLoader.packs = get_list()
	PackLoader.update_list()

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

	# Check if the path is already loaded
	if PackLoader.packs.find(path) >= 0: return

	# Load the pack
	$Packs.add_item(path)

	# Update the pack list
	submit_changes()

func toggle_packs() -> void:

	# Get selected items
	var items = $Packs.get_selected_items()
	var enable

	# For each
	for item in items:

		var text := $Packs.get_item_text(item) as String
		var disabled = text.begins_with("(disabled)")

		# If no mode is set, set it to toggle the first item to reverse state
		if enable == null: enable = disabled

		# Enable mode & disabled
		if enable and disabled:

			# Enable it
			$Packs.set_item_text(item, text.trim_prefix("(disabled)").strip_edges())

		# Disable mode and enabled
		elif not enable and not disabled:

			# Disable it
			$Packs.set_item_text(item, "(disabled) " + text)

	# Submit the changes
	submit_changes()

	# Update menus
	toggle(0, true)

func remove_packs() -> void:

	# Get selected items
	var items = $Packs.get_selected_items()

	# Get each item
	for item in items:

		# Remove from the list
		$Packs.remove_item(item)

	# Update the pack list
	submit_changes()

func toggle(_index = 0, status = true) -> void:

	status = not status
	$Buttons/Toggle.disabled = status
	$Buttons/Remove.disabled = status

	# Enabling
	if not status:

		# Get first selected item
		var item := $Packs.get_selected_items()[0] as int
		var text := $Packs.get_item_text(item) as String

		# Set it as the mode
		$Buttons/Toggle.text = "Enable" if text.begins_with("(disabled)") else "Disable"

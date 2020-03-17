extends HSplitContainer

func _ready() -> void:

	# Connect buttons
	$Buttons/Add.connect("pressed", self, "add_pack")

	# Connect list
	$Packs.connect("item_selected", self, "disable", [false])
	$Packs.connect("nothing_selected", self, "disable", [0, true])

	# Wait for new packs
	PackLoader.connect("pack_loaded", self, "list_pack")

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

func list_pack(path: String) -> void:

	$Packs.add_item(path)

func disable(_index = 0, status = true) -> void:

	$Buttons/Edit.disabled = status
	$Buttons/Toggle.disabled = status
	$Buttons/Remove.disabled = status

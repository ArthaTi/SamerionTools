extends "res://src/Tools/Tool.gd"

func _process(delta: float) -> void:

	# Ignore if this tool isn't active
	if not is_active(): return

	# Disable zoom if there are any selected tiles
	EditorApi.camera_control.zoom_enabled = not get_tree().get_nodes_in_group("selected").size()

func _input(event: InputEvent) -> void:

	# Ignore if this tool isn't active
	if not is_active(): return

	# Ignore empty events
	if not event is InputEventMouseButton: return

	# If scrolling
	if event.is_pressed() and (event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN):

		# Get all selected cells
		for cell in get_tree().get_nodes_in_group("selected"):

			# Update height
			cell.height += 0.1 if event.button_index == BUTTON_WHEEL_DOWN else -0.1

func is_active():

	return get_parent().active_tool == self or Input.is_key_pressed(KEY_ALT)

func input(event: InputEventMouseButton, pos: Vector2):

	# Enable selection
	input_select(event, pos)

extends "res://src/Tools/Tool.gd"

var active_state = false

func _process(delta: float) -> void:

	# Check if the tool active state changed
	var active_now = is_active()

	# Ignore if it didn't
	if active_state == active_now: return

	# Update the status
	active_state = active_now

	# Disable zoom if there are any selected tiles
	EditorApi.camera_control.zoom_enabled = (
		not is_active()
		or not get_tree().get_nodes_in_group("selected").size()
	)

func _unhandled_input(event: InputEvent) -> void:

	# Ignore if this tool isn't active
	if not is_active(): return

	# Ignore empty events
	if not event is InputEventMouseButton: return

	# If scrolling
	if event.is_pressed() and (event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN):

		# Get all selected cells
		for cell in get_tree().get_nodes_in_group("selected"):

			# Update height
			cell.height += -0.1 if event.button_index == BUTTON_WHEEL_DOWN else 0.1

func is_active():

	return get_parent().active_tool == self or Input.is_key_pressed(KEY_ALT)

func input(event: InputEventMouseButton, pos: Vector2):

	# Enable selection
	input_select(event, pos)

extends "res://src/Tools/Tool.gd"

const Cell = preload("res://src/AreaDisplay/Cell.gd")

var preview_cell: Cell
var last_position  # null if not holding
var is_pressed := false
var erase := false

signal preview_cell_updated

func _ready():

	preview_cell = Cell.new("grass", 0)
	preview_cell.name = "PreviewCell"
	preview_cell.modulate = Color(0, 0.53, 0.67, 0.9)
	preview_cell.height_label.show()
	EditorApi.area_display.add_child(preview_cell)
	preview_cell.set_process_unhandled_input(false)

func _process(delta: float) -> void:

	# Check if this tool is active
	var active = get_parent().active_tool == self

	# Change preview_cell visiblity based on that
	preview_cell.visible = active

	# Set preview_cell position
	preview_cell.map_position = (
		$"/root/Editor".get_global_mouse_position()
		/ preview_cell.target_size
		+ Vector2(0, preview_cell.height / 2)
	).floor()
	preview_cell.z_index += 1

	# If position changed
	if preview_cell.map_position != last_position:

		last_position = preview_cell.map_position

		emit_signal("preview_cell_updated")

		# Get previously labeled cells
		for cell in get_tree().get_nodes_in_group("labeled"):

			# Hide them
			cell.height_label.hide()

			# Remove from the group
			cell.remove_from_group("labeled")

		# Enable height labels on neighbor tiles
		for cell in CellIterator.new(
			EditorApi.area_display,
			Rect2(preview_cell.map_position - Vector2(1, 1), Vector2(2, 2))
		):

			# Show them
			cell.height_label.show()

			# Mark as labeled
			cell.add_to_group("labeled")

		# If pressing the left button
		if (
			active and is_pressed
			and not Input.is_key_pressed(KEY_SHIFT) and not Input.is_key_pressed(KEY_CONTROL)
		):

			# Painting
			if not erase:

				# Place the tile
				EditorApi.area_display.set_tile(
					preview_cell.map_position,
					preview_cell.type,
					preview_cell.height
				)

			# Erasing
			else:

				# Remove the tile
				EditorApi.area_display.reset_cell(
					preview_cell.map_position
				)

	if not active: return

	# Toggle zoom based on (alt) state
	EditorApi.camera_control.zoom_enabled = not Input.is_key_pressed(KEY_ALT)

func _unhandled_input(event: InputEvent) -> void:

	# Enable changing height of target tile
	if event is InputEventMouseButton:

		# Changing height of target tile
		if event.alt:

			if not event.is_pressed(): return

			match event.button_index:

				# Scrolling up
				BUTTON_WHEEL_UP:

					# Go up
					preview_cell.height += 0.1
					emit_signal("preview_cell_updated")

				# Scrolling down
				BUTTON_WHEEL_DOWN:

					# Go down
					preview_cell.height -= 0.1
					emit_signal("preview_cell_updated")

		# Painting tiles
		else:

			# Pressed left or right button
			if event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT:

				# Set mode
				erase = event.button_index == BUTTON_RIGHT

				# No matter if just pushed or released, nullify last position
				last_position = null

				# Set if pressed or not
				is_pressed = event.is_pressed()

func input(event: InputEventMouseButton, pos: Vector2):

	# Enable selection
	input_select(event, pos)

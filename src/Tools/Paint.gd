extends "res://src/Tools/Tool.gd"

const Cell = preload("res://src/AreaDisplay/Cell.gd")

var preview_cell: Cell
var last_position  # null if not holding

signal preview_cell_changed

func _ready():

	preview_cell = Cell.new("grass", 0)
	preview_cell.name = "PreviewCell"
	preview_cell.modulate = Color(0, 0.53, 0.67, 0.9)
	EditorApi.area_display.add_child(preview_cell)

func _process(delta: float) -> void:

	# Check if this tool is active
	var active = get_parent().active_tool == self

	# Change preview_cell visiblity based on that
	preview_cell.visible = active

	# Set preview_cell position
	preview_cell.map_position = (
		EditorApi.area_display.get_local_mouse_position()
		/ preview_cell.target_size
		+ Vector2(0, preview_cell.height / 2).floor()
	).floor()
	preview_cell.z_index += 1

	# If position changed
	if preview_cell.map_position != last_position and Input.is_mouse_button_pressed(BUTTON_LEFT):

		# Place the tile
		EditorApi.area_display.set_tile(
			preview_cell.map_position,
			preview_cell.type,
			preview_cell.height
		)

	# Toggle zoom based on (alt) state
	EditorApi.camera_control.zoom_enabled = not Input.is_key_pressed(KEY_ALT)

func _input(event: InputEvent) -> void:

	# Enable changing height of target tile
	if event is InputEventMouseButton:

		# Changing height of target tile
		if event.alt:

			match event.button_index:

				# Scrolling up
				BUTTON_WHEEL_UP:

					# Go up
					preview_cell.height += 0.1
					continue

				# Scrolling down
				BUTTON_WHEEL_DOWN:

					# Go down
					preview_cell.height -= 0.1
					continue

		# Paint tile
		if event.button_index == BUTTON_LEFT:

			# No matter if just pushed or released, nullify last position
			last_position = null

func input(event: InputEventMouseButton, pos: Vector2):

	# Enable selection
	input_select(event, pos)

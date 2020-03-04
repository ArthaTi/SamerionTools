extends Button

const CellIterator = preload("res://src/AreaDisplay/CellIterator.gd")

var select_begin: Vector2
var select_begin_precise

# Enable selection via input_select() without modifiers, used in the select tool
var main_selection = false

func input(event: InputEventMouseButton, pos: Vector2): pass

func input_select(event: InputEventMouseButton, pos: Vector2):

	# Ignore if neither shift nor control are pressed, unless this is a selection container
	if not main_selection and not event.shift and not event.control: return

	# Match the button
	match event.button_index:

		# Left button
		BUTTON_LEFT:

			# Start selection
			if event.is_pressed():

				# Ignore if shift is pressed and there are any selected cells
				if event.shift and get_tree().get_nodes_in_group("selected"): return

				# Mark the current position as the beginning
				select_begin = pos

				# Mark as holding
				select_begin_precise = $"/root/Editor".get_global_mouse_position()

				# Clear selection, unless pressing [ctrl]
				if not event.control: clear_selection()

			else:

				var min_coords = Vector2(
					min(select_begin.x, pos.x),
					min(select_begin.y, pos.y)
				)
				var max_coords = Vector2(
					max(select_begin.x, pos.x),
					max(select_begin.y, pos.y)
				)

				# Mark as not holding
				select_begin_precise = null
				EditorApi.selection.rect = Rect2()

				# Clear selection if [shift] is pressed and [ctrl] isn't
				if event.shift and not event.control: clear_selection()

				# Select the rect
				for cell in CellIterator.new(EditorApi.area_display, Rect2(min_coords, max_coords)):

					# If shift is pressed, select the cell
					if event.shift: cell.select()

					# Toggle selection otherwise
					else: cell.toggle_selection()

# Clear selection
func clear_selection():

	# Get all selected cells
	for cell in get_tree().get_nodes_in_group("selected"):

		# Unselect them
		cell.remove_from_group("selected")

		# Refresh them
		cell.update()

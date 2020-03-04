extends "res://src/Tools/Tool.gd"

func _init() -> void:

	main_selection = true

func _process(delta: float) -> void:

	if select_begin_precise:

		EditorApi.selection.rect = Rect2(
			select_begin_precise,
			$"/root/Editor".get_global_mouse_position() - select_begin_precise
		)

func _input(event: InputEvent):

	# Left mouse button is up
	if (event is InputEventMouseButton
		and event.button_index == BUTTON_LEFT
		and not event.is_pressed()):

		select_begin_precise = null
		EditorApi.selection.rect = Rect2()

func input(event, pos):

	input_select(event, pos)

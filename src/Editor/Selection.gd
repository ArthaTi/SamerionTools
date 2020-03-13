extends Node2D

var rect: Rect2

func _ready() -> void:

	EditorApi.selection = self

func _process(delta: float) -> void:

	update()

func _draw():

	if not rect: return

	# Draw background
	draw_rect(
		rect,
		Color(0, 0.53, 0.67, 0.5)
	)

	# Draw border
	draw_rect(
		rect,
		Color(0, 0, 1),
		false
	)

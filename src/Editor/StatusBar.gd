extends HBoxContainer

onready var paint = EditorApi.tools.get_node("Paint")

func _ready() -> void:

	paint.connect("preview_cell_updated", self, "update_paint_position")

func update_paint_position():

	$PaintPosition.text = str(paint.preview_cell.map_position)

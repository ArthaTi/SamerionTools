extends HBoxContainer

onready var paint = EditorApi.tools.get_node("Paint")
onready var warning_dialog = $"../../../WarningDialog"
var _warnings := {}

func _ready() -> void:

	paint.connect("preview_cell_updated", self, "update_paint_position")
	$Warnings.connect("pressed", warning_dialog, "show")

	EditorApi.status_bar = self

func add_warning(id: String, text: String):

	_warnings[id] = text
	refresh_warnings()

func remove_warning(id: String):

	_warnings.erase(id)
	refresh_warnings()

func refresh_warnings():

	var text := ""

	# Get text from all warnings
	for key in _warnings:

		# Add to given text
		text += _warnings[key] + "\n\n"

	# Set dialog text
	warning_dialog.dialog_text = text

	$Warnings.text = "%s warning%s" % [ _warnings.size(), "s" if _warnings.size() != 1 else "" ]

func update_paint_position():

	$PaintPosition.text = str(paint.preview_cell.map_position)

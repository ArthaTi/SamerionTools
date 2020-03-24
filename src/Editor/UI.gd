extends CanvasLayer

onready var pack_manager: WindowDialog = $PackManager
onready var file_dialog: FileDialog = $FileDialog
onready var warning_dialog: AcceptDialog = $WarningDialog

func _ready() -> void:

	EditorApi.ui = self

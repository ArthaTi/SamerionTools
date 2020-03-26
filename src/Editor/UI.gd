extends CanvasLayer

const PackManager = preload("PackManager.gd")
const MapSettings = preload("MapSettings.gd")

onready var pack_manager: PackManager = $PackManager
onready var file_dialog: FileDialog = $FileDialog
onready var warning_dialog: AcceptDialog = $WarningDialog
onready var map_settings: MapSettings = $MapSettings

func _ready() -> void:

	EditorApi.ui = self

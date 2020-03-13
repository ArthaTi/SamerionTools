extends PanelContainer

const Cell = preload("res://src/AreaDisplay/Cell.gd")

onready var paint = EditorApi.tools.get_node("Paint")

func _ready() -> void:

	# Connect inputs
	$Wrapper/Tile/Tile.connect("text_changed", self, "input")
	$Wrapper/Tile/Height.connect("value_changed", self, "input")

	# Subscribe to tile updates
	paint.connect("preview_cell_updated", self, "updated")

func input(_text = ""):

	# Get the preview cell
	var preview := paint.preview_cell as Cell

	preview.type = $Wrapper/Tile/Tile.text
	preview.height = $Wrapper/Tile/Height.value

	# Update textures
	preview.generate_variants(0)

	# Update tile preview
	$Wrapper/Tile/Preview.texture = preview.texture

func updated():

	# Check if type changed
	if $Wrapper/Tile/Tile.text != paint.preview_cell.type:
		$Wrapper/Tile/Tile.text = paint.preview_cell.type

	# Check if height changed
	if $Wrapper/Tile/Height.value != paint.preview_cell.height:
		$Wrapper/Tile/Height.value = paint.preview_cell.height

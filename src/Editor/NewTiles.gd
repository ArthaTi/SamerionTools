extends PanelContainer

const Cell = preload("res://src/AreaDisplay/Cell.gd")

onready var paint = EditorApi.tools.get_node("Paint")
onready var preview := paint.preview_cell as Cell

func _ready() -> void:

	# Connect inputs
	$Wrapper/Tile/Tile.connect("text_changed", self, "input")
	$Wrapper/Tile/Height.connect("value_changed", self, "input")

	# Connect buttons
	$Wrapper/Apply.connect("pressed", self, "apply")

	# Subscribe to tile updates
	paint.connect("preview_cell_updated", self, "updated")

func input(_text = "") -> void:

	preview.type = $Wrapper/Tile/Tile.text
	preview.height = $Wrapper/Tile/Height.value

	# Update textures
	preview.generate_variants(0)

	# Update tile preview
	$Wrapper/Tile/Preview.texture = preview.texture

func updated() -> void:

	# Check if type changed
	if $Wrapper/Tile/Tile.text != paint.preview_cell.type:
		$Wrapper/Tile/Tile.text = paint.preview_cell.type

	# Check if texture changed
	if $Wrapper/Tile/Preview.texture != preview.texture:
		$Wrapper/Tile/Preview.texture = preview.texture

	# Check if height changed
	if $Wrapper/Tile/Height.value != paint.preview_cell.height:
		$Wrapper/Tile/Height.value = paint.preview_cell.height

func apply() -> void:

	# Get each selected tool
	for cell in get_tree().get_nodes_in_group("selected"):

		# Paint them and select
		EditorApi.tools.get_node("Paint").paint_tile(cell.map_position).select()

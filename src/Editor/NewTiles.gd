extends PanelContainer

func _ready() -> void:

	$Wrapper/Tile/Tile.connect("text_changed", self, "input")

func _process(delta: float) -> void:

	pass

func input():

	pass

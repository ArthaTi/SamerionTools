extends HBoxContainer

var deg := 0

func _ready() -> void:

	$Left.connect("pressed", self, "change", [-90])
	$Right.connect("pressed", self, "change", [+90])

func change(by: int) -> void:

	deg = posmod(deg + by, 360)
	$Label.text = "%s°" % deg

	EditorApi.area_display.view_from = deg / 90

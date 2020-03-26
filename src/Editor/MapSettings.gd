extends WindowDialog

var map

func _ready() -> void:

	# Update the data based on visibility
	connect("visibility_changed", self, "_visibility_changed")

	# Hide if pressed the close button
	$Wrapper/Close.connect("pressed", self, "hide")
	$Wrapper/VariantSeed/Randomize.connect("pressed", self, "new_seed")

func _visibility_changed():

	# Load data
	if visible:

		map = EditorApi.area_display.map

		$Wrapper/ID.text = map.id
		$Wrapper/Name.text = map.map_name
		$Wrapper/VariantSeed/Value.value = map.variant_seed

	# Save the data
	else:

		if map.id != $Wrapper/ID.text: map.changed = true
		elif map.map_name != $Wrapper/Name.text: map.changed = true
		elif map.variant_seed != $Wrapper/VariantSeed/Value.value: map.changed = true

		map.id = $Wrapper/ID.text
		map.map_name = $Wrapper/Name.text
		map.variant_seed = $Wrapper/VariantSeed/Value.value

func new_seed():

	# Create a random number generator
	var rng = RandomNumberGenerator.new()

	# With a new seed
	rng.randomize()

	# Use the seed
	$Wrapper/VariantSeed/Value.value = rng.seed
	map.variant_seed = rng.seed

func show(warning = ""):

	$Wrapper/WarningLabel.text = "⚠⚠⚠\u26a0" if warning else ""
	$Wrapper/Warning.text = warning

	.show()

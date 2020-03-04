extends Sprite

const target_size = 128
const neighbor_positions = [
	Vector2( 0, -1),
	Vector2(+1,  0),
	Vector2( 0, +1),
	Vector2(-1,  0),
]

var type: String
var map_position: Vector2 setget set_map_position
var height: float setget set_height
var variant: int
var decoration: int

var object: String
var objectSpawner: String

func _init(type: String, variantSeed: int) -> void:

	# Do not center
	centered = false

	# Assign properties
	self.type = type

	# Add subnodes
	var side := Sprite.new()
	side.name = "Side"
	side.centered = false
	add_child(side)

	# Generate variants
	generate_variants(variantSeed)

# TODO: instead of bruting through inputs, add a mapping of height-corrected coords somewhere
func _input(event: InputEvent) -> void:

	# Filter: Clicked or released a button somewhere
	if not event is InputEventMouseButton: return

	# Check if the event is in the bounding box of this cell
	if get_rect().has_point(get_global_mouse_position()):

		# Call the event
		EditorApi.tools.input(event, map_position)

func _draw():

	# Draw selection
	if not is_in_group("selected"): return

	# Get texture size
	var texture_size := texture.get_size()

	# Draw the square
	draw_rect(
		Rect2(Vector2(), texture_size),
		Color(0, 0.53, 0.67, 0.5)
	)

	var display = get_parent()

	# Draw borders
	for relative_pos in neighbor_positions:

		# Get the neighbor
		var neighbor = relative_tile(relative_pos)

		# Ignore if there is a selected neighbor with the same height
		if neighbor and neighbor.is_in_group("selected") and neighbor.height == height: continue

		# Draw on the border, based on the relative_position
		# Note that -1 maps to 0
		draw_line(

			# Get the .from value: 0 → 0, inherit otherwise (only 1 gives 1)
			texture_size * Vector2(
				int(relative_pos.x == +1),
				int(relative_pos.y == +1)
			),

			# Get the .to value: 0 → 1, inherit otherwise (only -1 gives 0)
			texture_size * Vector2(
				int(relative_pos.x != -1),
				int(relative_pos.y != -1)
			),

			# Color: plain blue
			Color(0, 0, 1)

		)

func toggle_selection():

	# If the cell is already selected
	if is_in_group("selected"):

		# Unselect it
		remove_from_group("selected")

	# And select it if it isn't
	else: add_to_group("selected")

	# Refresh it
	update_area()

func select():

	add_to_group("selected")
	update_area()

func relative_tile(relative_pos: Vector2):

	var pos = map_position + relative_pos
	return get_parent().get_tile(pos)

func set_map_position(pos: Vector2):

	# Set the value
	map_position = pos

	# Set actual position
	update_position()

func set_height(val: float):

	# Set the value
	height = val

	# Set actual position
	update_position()

func update_position():

	position = target_size * (map_position + Vector2(0, height/2))

func update_area():

	# Update self first
	update()

	# Update neighbours
	for pos in neighbor_positions:

		# Get the neighbor
		var neighbor = relative_tile(pos)

		# Update it, if it exists
		if neighbor: neighbor.update()

func get_rect():

	return Rect2(position, Vector2(target_size, target_size))

func is_pressed():

	return Input.is_mouse_button_pressed(BUTTON_LEFT) and get_rect().has_point(get_local_mouse_position())

func generate_variants(variantSeed: int):

	# Main texture
	texture = PackLoader.load_tile(type, "tile", variantSeed)

	# Scale to fit target size
	scale = Vector2(target_size, target_size) / texture.get_size()

	# Load the side's texture
	$Side.texture = PackLoader.load_tile(type, "side", variantSeed + 1)
	$Side.position = Vector2(0, target_size) / scale

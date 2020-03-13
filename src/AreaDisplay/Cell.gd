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
var height: float = 1 setget set_height
var variant: int
var decoration: int

var object: String
var objectSpawner: String

var height_label: Label
var side: Sprite
var side_repeat: Sprite

func _init(type: String, variantSeed: int) -> void:

	# Do not center
	centered = false

	# Assign properties
	self.type = type

	# Add the height label
	height_label = Label.new()
	height_label.name = "HeightLabel"
	height_label.rect_size = Vector2(target_size, target_size)
	height_label.hide()
	height_label.align = Label.ALIGN_CENTER
	height_label.valign = Label.VALIGN_CENTER
	height_label.set("custom_colors/font_color", Color.white)
	height_label.set("custom_colors/font_color_shadow", Color(0, 0, 0, 0.5))
	height_label.set("custom_constants/shadow_as_outline", true)
	add_child(height_label)

	# Add the Side subnode
	side = Sprite.new()
	side.name = "Side"
	side.centered = false
	add_child(side)

	# Add the SideRepeat subnode
	side_repeat = Sprite.new()
	side_repeat.name = "SideRepeat"
	side_repeat.centered = false
	add_child(side_repeat)

	# Generate variants
	generate_variants(variantSeed)

# When assigned to a tree
func _ready() -> void:

	update_position()

# TODO: instead of bruting through cells, add a mapping of height-corrected coords somewhere
func _unhandled_input(event: InputEvent) -> void:

	# If clicked or released a button somewhere
	if not event is InputEventMouseButton: return

	# As long as this cell is still in the tree
	if get_parent() == null: return

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
		select(false)

	# And select it if it isn't
	else: select(true)

	# Refresh it
	update_area()

func select(value := true):

	if value:
		add_to_group("selected")
	else:
		remove_from_group("selected")

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

	# Update height label
	height_label.text = str(val)

func update_position():

	position = target_size * (map_position - Vector2(0, height/2))
	z_index = map_position.y

	# If assigned to an area
	if get_parent():

		# Update the side
		update_side()

		# Update the side of the cell in behind
		var backTile = get_parent().get_tile(map_position - Vector2(0, 1))
		if backTile: backTile.update_side()

func update_side():

	# If the side texture isn't present
	if not side.texture: return

	# Get the tile in front of this one
	var frontTile = get_parent().get_tile(map_position + Vector2(0, 1))
	var frontTileHeight = frontTile.height if frontTile else height

	# Get texture ratio of the side
	var textureSize = side.texture.get_size()
	var textureRatio = textureSize.y / textureSize.x

	# Set the repeat box to match that texture
	side_repeat.region_rect = Rect2(
		0, 0,  # I have no idea why that "/2" at the end is necessary, it really shouldn't
		textureSize.x, textureSize.y * max(0, height/2 - frontTileHeight/2 - textureRatio) / 2
	)

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

	# Get the main texture
	var new_texture = PackLoader.load_tile(type, "tile", variantSeed)

	# If the tile doesn't exist
	if new_texture == null:

		# If there is no texture set at all
		if texture == null:

			# Mark as missing
			add_to_group("missing")

		# Ignore it
		return

	remove_from_group("missing")

	# Assign the texture
	texture = new_texture

	# Scale to fit target size
	scale = Vector2(target_size, target_size) / texture.get_size()

	# Set height label scale
	height_label.rect_scale = Vector2(1, 1) / scale

	# Load the side's texture
	var sideTexture = PackLoader.load_tile(type, "side", variantSeed + 1)
	side.texture = sideTexture
	side.position = Vector2(0, target_size) / scale

	# Crop the image
	var textureSize = sideTexture.get_size()
	var textureRatio = textureSize.y / textureSize.x
	var image: Image = sideTexture.get_data().get_rect(Rect2(
		0, textureSize.y - textureSize.x,
		textureSize.x, textureSize.x
	))
	var croppedTexture := ImageTexture.new()
	croppedTexture.create_from_image(image)
	croppedTexture.flags = side.texture.flags | Texture.FLAG_REPEAT

	# Load the sideRepeat texture
	side_repeat.texture = croppedTexture
	side_repeat.position = Vector2(0, target_size * (1 + textureRatio)) / scale
	side_repeat.region_enabled = true

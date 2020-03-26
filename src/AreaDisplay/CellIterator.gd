extends Resource

const Map = preload("Map.gd")
const Cell = preload("Cell.gd")

var map: Map
var rect: Rect2
var current: Vector2
var skip_nulls: bool

func _init(map: Map, rect: Rect2, skip_nulls := true):

	self.map = map
	self.rect = rect
	self.skip_nulls = skip_nulls

func in_progress():

	return (current.x <= rect.end.x
		and current.y <= rect.end.y)

func _iter_init(_arg):

	current = rect.position

	# Check for nulls at the start
	if skip_nulls: _iter_next("", false)

	return in_progress()

func _iter_next(_arg, start=true):

	while start or (skip_nulls and _iter_get() == null):

		start = false

		# If ended the row
		if current.x >= rect.end.x:

			# Go to next row
			current.y += 1
			current.x = rect.position.x

			# If ended the iteration
			if current.y > rect.end.y:

				return false

		# Continue the current row
		else:

			current.x += 1

	return in_progress()

func _iter_get(_arg = null) -> Cell:

	return map.coords.get(current)

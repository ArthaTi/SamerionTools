const AreaDisplay = preload("res://src/AreaDisplay/AreaDisplay.gd")
const Cell = preload("res://src/AreaDisplay/Cell.gd")

var area: AreaDisplay
var rect: Rect2
var current: Vector2

func _init(area: AreaDisplay, rect: Rect2):

	self.area = area
	self.rect = rect

func in_progress():

	return (current.x <= rect.end.x
		and current.y <= rect.end.y)

func _iter_init(_arg):

	current = rect.position

	return in_progress()

func _iter_next(_arg):

	var start = true

	while start or area.get_tile(current) == null:

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

func _iter_get(_arg):

	return area.get_tile(current)

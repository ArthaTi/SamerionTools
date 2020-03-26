extends Resource

var current
var start
var end
var step

func _init(start, end = null, step = 1) -> void:

	self.step = step

	# If didn't provide an end
	if end == null:

		self.start = 0
		self.end = start

	else:

		self.start = start
		self.end = end

func in_progress():

	return self.current < self.end

func _iter_init(_arg):

	self.current = self.start
	return in_progress()

func _iter_next(_arg):

	self.current += self.step
	return in_progress()

func _iter_get(_arg):

	return self.current

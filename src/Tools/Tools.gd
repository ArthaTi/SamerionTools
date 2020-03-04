extends Node

const Tool = preload("res://src/Tools/Tool.gd")

onready var active_tool: Tool = $Paint

signal received_input()

func _ready():

	# Bind tool buttons
	$Edit.connect("pressed", self, "set_tool", [$Edit])
	$Paint.connect("pressed", self, "set_tool", [$Paint])
	$Select.connect("pressed", self, "set_tool", [$Select])

	# Register self in editor API
	EditorApi.tools = self

func set_tool(value: Tool):

	active_tool = value

func input(input: InputEventMouseButton, pos: Vector2):

	active_tool.input(input, pos)

	emit_signal("received_input")

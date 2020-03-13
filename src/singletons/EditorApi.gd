extends Node

const Tools = preload("res://src/Tools/Tools.gd")
const AreaDisplay = preload("res://src/AreaDisplay/AreaDisplay.gd")
const Selection = preload("res://src/Editor/Selection.gd")
const CameraControl = preload("res://src/Editor/CameraControl.gd")
const StatusBar = preload("res://src/Editor/StatusBar.gd")

var tools: Tools
var area_display: AreaDisplay
var selection: Selection
var camera_control: CameraControl
var status_bar: StatusBar

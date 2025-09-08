class_name GrabbableArea
extends Area3D

@export var left_grab_point: Marker3D
@export var right_grab_point: Marker3D

@onready var object: GrabbableObject = get_parent()

func _ready() -> void:
	if !left_grab_point || !right_grab_point:
		push_error("GrabbableArea requires a grab_point")
		return

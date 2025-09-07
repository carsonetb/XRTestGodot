class_name GrabbableArea
extends Area3D

@export var grab_point: Marker3D

@onready var object: GrabbableObject = get_parent()

func _ready() -> void:
	if !grab_point:
		push_error("GrabbableArea requires a grab_point")
		return

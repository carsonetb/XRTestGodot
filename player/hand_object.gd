class_name HandObject
extends RigidBody3D

@export var is_left: bool
@export var attach_point: Marker3D
@export var local_object_point: Marker3D

func _ready() -> void:
	if is_left:
		$right_hand.visible = false
	else:
		$left_hand.visible = false

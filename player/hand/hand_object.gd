class_name HandObject
extends RigidBody3D

@export var is_left: bool
@export var attach_point: Marker3D
@export var local_object_point: Marker3D

@export var left_hand: HandModel
@export var right_hand: HandModel

func _ready() -> void:
	if is_left:
		$RightCollision.disabled = true
		right_hand.visible = false
	else:
		$LeftCollision.disabled = true
		left_hand.visible = false

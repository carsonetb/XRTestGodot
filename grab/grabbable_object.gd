class_name GrabbableObject
extends RigidBody3D

@export var dont_rescale: bool = false

@onready var bullet_scene = preload("uid://c7rl0pq345pge")
@onready var shell_scene = preload("uid://cgjsr6aor6oqm")
@onready var shoot_sound_array: Array[AudioStream] = [
	preload("uid://dwcxtt64e0tx"),
	preload("uid://c87gbqn3jglla"),
	preload("uid://djgp568yjerys"),
	preload("uid://bailxcialribe"),
	preload("uid://dyq0dbtvnboom"),
]

var primary_hand: Hand
var secondary_hand: Hand
var collisions: Array[CollisionShape3D]

func _ready() -> void:
	for child in get_children():
		if child is CollisionShape3D:
			collisions.append(child)

func use() -> void:
	pass

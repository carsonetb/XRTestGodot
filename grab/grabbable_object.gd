class_name GrabbableObject
extends RigidBody3D

@export var bullet_spawn_pos: Marker3D
@export var shell_spawn_pos: Marker3D

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

func use() -> void:
	apply_central_impulse(global_basis.z * 200)
	
	var bullet: RigidBody3D = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.rotation = rotation
	bullet.linear_velocity = -global_transform.basis.z * 4000
	bullet.global_position = bullet_spawn_pos.global_position
	bullet.scale = Vector3(0.05, 0.05, 0.05)
	
	var shell: RigidBody3D = shell_scene.instantiate()
	get_parent().add_child(shell)
	shell.linear_velocity = global_transform.basis.x * 50
	shell.global_position = shell_spawn_pos.global_position
	shell.apply_torque_impulse(Vector3(randf_range(-50, 50), randf_range(-50, 50), randf_range(-50, 50)))
	shell.scale = Vector3(0.033, 0.033, 0.033)
	
	primary_hand.trigger_haptic_pulse("haptic", 0.0, 1.0, 0.2, 0)
	if secondary_hand:
		secondary_hand.trigger_haptic_pulse("haptic", 0.0, 0.6, 0.2, 0)
	
	var new_audio: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	new_audio.stream = shoot_sound_array.pick_random()
	add_child(new_audio)
	new_audio.play()

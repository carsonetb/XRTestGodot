extends XRController3D

@export var bullet_spawn_pos: Node3D
@export var shell_spawn_pos: Node3D
@export var gun: RigidBody3D

@onready var bullet_scene = preload("uid://c7rl0pq345pge")
@onready var shell_scene = preload("uid://cgjsr6aor6oqm")

@export var shoot_sound_array: Array[AudioStream] = [
	preload("uid://dwcxtt64e0tx"),
	preload("uid://c87gbqn3jglla"),
	preload("uid://djgp568yjerys"),
	preload("uid://bailxcialribe"),
	preload("uid://dyq0dbtvnboom"),
]

func euler_angle_lerp(a: Vector3, b: Vector3, weight: float) -> Vector3:
	return Vector3(a.x + ((b.x - a.x) * weight), a.y + ((b.y - a.y) * weight), a.z + ((b.z - a.z) * weight))

func _physics_process(delta: float) -> void:
	var direction: Vector3 = gun.global_position.direction_to(global_position)
	var distance: float = gun.global_position.distance_to(global_position)
	gun.apply_central_force(direction * min(distance * 1000, 150))
	gun.rotation = euler_angle_lerp(gun.rotation, rotation, 0.3)

func _on_button_pressed(name: String) -> void:
	if name == "trigger_click":
		gun.apply_central_impulse(gun.global_basis.z * 200)
		
		var bullet: RigidBody3D = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.rotation = rotation
		bullet.linear_velocity = -global_transform.basis.z * 40
		bullet.global_position = bullet_spawn_pos.global_position
		bullet.scale = Vector3(0.033, 0.033, 0.033)
		
		var shell: RigidBody3D = shell_scene.instantiate()
		get_parent().add_child(shell)
		shell.linear_velocity = global_transform.basis.x * 2
		shell.global_position = shell_spawn_pos.global_position
		shell.apply_torque_impulse(Vector3(randf_range(-20, 20), randf_range(-20, 20), randf_range(-20, 20)))
		shell.scale = Vector3(0.033, 0.033, 0.033)
		
		trigger_haptic_pulse("haptic", 0.0, 1.0, 0.2, 0)
		
		var new_audio: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		new_audio.stream = shoot_sound_array.pick_random()
		add_child(new_audio)
		new_audio.play()
	

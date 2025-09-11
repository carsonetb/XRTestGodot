class_name Player
extends RigidBody3D

@export var player_xr_nodes: PlayerXRNodes

func _process(_delta: float) -> void:
	player_xr_nodes.global_position = global_position
	var player_height: float = abs(player_xr_nodes.camera.global_position.y - player_xr_nodes.global_position.y) - 0.25 # for the head
	var shape: CapsuleShape3D = $Collision.shape
	shape.height = player_height
	$Collision.position.y = player_height / 2.0
	var mesh: CapsuleMesh = $BodyMesh.mesh
	mesh.height = player_height
	$BodyMesh.position.y = player_height / 2.0

func _physics_process(_delta: float) -> void:
	var movement: Vector2 = player_xr_nodes.left_hand.get_vector2("movement").rotated(player_xr_nodes.camera.rotation.y) * 1.4 # average human walking speed
	linear_velocity.x = movement.x
	linear_velocity.z = -movement.y

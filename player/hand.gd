class_name Hand
extends XRController3D

@export var hand_object: HandObject
@export var hand_grab_point: Marker3D
@export var local_object_point: Marker3D
@export var is_left_hand: bool

var holding_object: GrabbableArea
var holding_offset: Vector3
var grabbables_in_area: Array[GrabbableArea]
var extra_rotation_force: float
var copied_collisions: Array[CollisionShape3D]
var is_animating_pickup: bool = false

func _process(_delta: float) -> void:
	var aim_pos = get_input("aim_pos")
	if aim_pos:
		position = aim_pos
	
	var grab_force = get_input("grab_force")
	if grab_force && grab_force > 0.3 && !grabbables_in_area.is_empty() && !holding_object:
		holding_object = grabbables_in_area[0]
		holding_object.object.primary_hand = self
		
		var grab_point: Marker3D
		if is_left_hand:
			grab_point = holding_object.left_grab_point
		else:
			grab_point = holding_object.right_grab_point
		
		holding_offset = -grab_point.position * holding_object.object.scale
		hand_object.local_object_point.position = hand_grab_point.position + holding_offset
		
		extra_rotation_force = holding_object.object.mass / hand_object.mass
		hand_object.mass += holding_object.object.mass
		
		is_animating_pickup = true
		
		for collision: CollisionShape3D in holding_object.object.collisions:
			var offset: Vector3 = (collision.position - grab_point.position) * holding_object.object.scale
			var copied: CollisionShape3D = collision.duplicate()
			collision.disabled = true
			hand_object.add_child(copied)
			copied.scale = holding_object.object.scale
			copied.position = hand_grab_point.position + offset
			copied_collisions.append(copied)
	
	if grab_force && grab_force < 0.5 && holding_object:
		for collision: CollisionShape3D in copied_collisions:
			collision.queue_free()
		copied_collisions.clear()
		for collision: CollisionShape3D in holding_object.object.collisions:
			collision.disabled = false
		holding_object.object.primary_hand = null
		holding_object.object.linear_velocity = hand_object.linear_velocity * 1.5
		holding_object.object.angular_velocity = hand_object.angular_velocity * 1.5
		hand_object.mass -= holding_object.object.mass
		holding_object = null
		extra_rotation_force = 0
	
	if !holding_object:
		return
	if !is_animating_pickup:
		holding_object.object.global_position = hand_object.local_object_point.global_position
		holding_object.object.rotation = hand_object.rotation
	else:
		holding_object.object.rotation += (hand_object.rotation - holding_object.object.rotation) * 0.1
		holding_object.object.global_position += (hand_object.local_object_point.global_position - holding_object.object.global_position) * 0.2
		if holding_object.object.global_position.distance_to(hand_object.local_object_point.global_position) < 0.005:
			is_animating_pickup = false

func _physics_process(_delta: float) -> void:
	var direction: Vector3 = hand_object.global_position.direction_to(global_position)
	var distance: float = hand_object.global_position.distance_to(global_position)
	hand_object.apply_central_force(direction * min(distance * 1000, 150))
	hand_object.apply_torque(Util.euler_angle_diff(hand_object.rotation, rotation) * (1.5 + extra_rotation_force))

func _on_button_pressed(button_name: String) -> void:
	if !holding_object:
		return
	if button_name == "shoot":
		holding_object.object.use()

func _on_object_detection_area_entered(area: Area3D) -> void:
	if !area is GrabbableArea:
		return
	
	grabbables_in_area.append(area as GrabbableArea)

func _on_object_detection_area_exited(area: Area3D) -> void:
	if !area is GrabbableArea:
		return
	
	grabbables_in_area.remove_at(grabbables_in_area.find(area as GrabbableArea))

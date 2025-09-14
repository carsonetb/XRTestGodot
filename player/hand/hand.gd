class_name Hand
extends XRController3D

@export var hand_object: HandObject
@export var hand_grab_point: Marker3D
@export var local_object_point: Marker3D
@export var is_left_hand: bool

var holding_object: GrabbableArea
var holding_offset: Vector3
var grabbables_in_area: Array[GrabbableArea]
var extra_rotation_force: Vector3 = Vector3.ONE
var copied_collisions: Array[CollisionShape3D]
var is_animating_pickup: bool = false
var start_rotation: Vector3
var inertia: Vector3
var previous_rotation: Vector3
var start_com: Vector3

func _ready() -> void:
	start_com = hand_object.center_of_mass

func _physics_process(_delta: float) -> void:
	var delta_rot: Vector3 = Util.euler_angle_diff(previous_rotation, rotation)
	
	hand_object.set_inertia(inertia)
	var direction: Vector3 = hand_object.global_position.direction_to(global_position)
	var distance: float = hand_object.global_position.distance_to(global_position)
	hand_object.apply_central_force(direction * min(distance * 1000, 400))
	
	# try to match velocity?
	if !holding_object || !holding_object.object.no_rotate_force:
		hand_object.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
		hand_object.center_of_mass = start_com
		hand_object.apply_torque(Util.euler_angle_diff(hand_object.rotation, rotation))
		hand_object.apply_torque(Util.euler_angle_diff(hand_object.angular_velocity, delta_rot) * 0.01) 
	
	previous_rotation = rotation
	
	var aim_pos = get_input("aim_pos")
	if aim_pos:
		position = aim_pos
	
	var grab_force = get_input("grab_force")
	var index_force = get_input("index_force")
	var thumb_force = get_input("thumb_force")
	
	if grab_force && grab_force > 0.7 && !grabbables_in_area.is_empty() && !holding_object:
		holding_object = grabbables_in_area[0]
		holding_object.object.primary_hand = self
		
		var grab_point: Marker3D
		if is_left_hand:
			grab_point = holding_object.left_grab_point
		else:
			grab_point = holding_object.right_grab_point
		
		start_rotation = Vector3.ZERO
		
		is_animating_pickup = true
		
		if holding_object.grab_at_any_point:
			var state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
			var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
			query.from = hand_object.global_position
			query.to = holding_object.object.global_position
			query.exclude.append(hand_object.get_rid())
			var out: Dictionary = state.intersect_ray(query)
			grab_point.global_position = out["position"]
			is_animating_pickup = false
		
		holding_offset = -grab_point.position * holding_object.object.scale
		hand_object.local_object_point.position = hand_grab_point.position + holding_offset
		
		var our_inertia: Vector3 = PhysicsServer3D.body_get_direct_state(hand_object.get_rid()).inverse_inertia.inverse()
		inertia = our_inertia
		
		holding_object.object.freeze = true
		
		hand_object.mass += holding_object.object.mass
		
		if holding_object.grab_at_any_point:
			holding_object.object.reparent(hand_object)
			
			for collision: CollisionShape3D in holding_object.object.collisions:
				var copied: CollisionShape3D = collision.duplicate()
				copied.disabled = true
				holding_object.object.add_child(copied)
				holding_object.object.collisions.append(copied)
				holding_object.object.collisions.remove_at(holding_object.object.collisions.find(collision))
				collision.reparent(hand_object)
				copied_collisions.append(collision)
		else:
			for collision: CollisionShape3D in holding_object.object.collisions:
				var offset: Vector3 = (collision.position - grab_point.position) * holding_object.object.scale
				var copied: CollisionShape3D = collision.duplicate()
				collision.disabled = true
				hand_object.add_child(copied)
				if !holding_object.object.dont_rescale:
					copied.scale = holding_object.object.scale
				copied.position = hand_grab_point.position + offset
				copied_collisions.append(copied)
	
	if grab_force && grab_force < 0.1 && holding_object:
		for collision: CollisionShape3D in copied_collisions:
			collision.queue_free()
		copied_collisions.clear()
		for collision: CollisionShape3D in holding_object.object.collisions:
			collision.disabled = false
		holding_object.object.reparent($"../../Objects")
		holding_object.object.primary_hand = null
		holding_object.object.freeze = false
		holding_object.object.linear_velocity = hand_object.linear_velocity * 1.5
		holding_object.object.angular_velocity = hand_object.angular_velocity * 1.5
		if holding_object.grab_at_any_point:
			holding_object.left_grab_point.position = Vector3.ZERO
			holding_object.right_grab_point.position = Vector3.ZERO
		hand_object.mass -= holding_object.object.mass
		holding_object = null
		extra_rotation_force = Vector3.ONE
	
	if grab_force:
		if is_left_hand:
			hand_object.left_hand.set_grip(grab_force)
		else:
			hand_object.right_hand.set_grip(grab_force)
	if index_force:
		if is_left_hand:
			hand_object.left_hand.set_index(index_force)
		else:
			hand_object.right_hand.set_index(index_force)
	if thumb_force:
		if is_left_hand:
			hand_object.left_hand.set_thumb(thumb_force)
		else:
			hand_object.right_hand.set_thumb(thumb_force)
	
	if !holding_object || holding_object.grab_at_any_point:
		return
	
	if !is_animating_pickup:
		holding_object.object.global_position = hand_object.local_object_point.global_position
		holding_object.object.rotation = hand_object.rotation
	else:
		holding_object.object.rotation += (hand_object.rotation - holding_object.object.rotation) * 0.1
		holding_object.object.global_position += (hand_object.local_object_point.global_position - holding_object.object.global_position) * 0.2
		if holding_object.object.global_position.distance_to(hand_object.local_object_point.global_position) < 0.005:
			is_animating_pickup = false

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

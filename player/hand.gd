class_name Hand
extends XRController3D

@export var hand_object: HandObject
@export var hand_grab_point: Marker3D
@export var is_left_hand: bool

var holding_object: GrabbableArea
var grabbables_in_area: Array[GrabbableArea]

func _process(delta: float) -> void:
	if !holding_object:
		return
	var object: GrabbableObject = holding_object.object
	var direction: Vector3 = holding_object.grab_point.global_position.direction_to(hand_grab_point.global_position)
	var distance: float = holding_object.grab_point.global_position.distance_to(hand_grab_point.global_position)
	object.apply_central_force(direction * min(distance * 400, 100))
	object.apply_torque(Util.euler_angle_diff(object.rotation, hand_object.rotation))

func _physics_process(_delta: float) -> void:
	var direction: Vector3 = hand_object.global_position.direction_to(global_position)
	var distance: float = hand_object.global_position.distance_to(global_position)
	hand_object.apply_central_force(direction * min(distance * 1000, 150))
	hand_object.apply_torque(Util.euler_angle_diff(hand_object.rotation, rotation) * 1.5)

func _on_button_pressed(button_name: String) -> void:
	if button_name == "grip_click" && !grabbables_in_area.is_empty() && !holding_object:
		holding_object = grabbables_in_area[0]
		holding_object.object.primary_hand = self
	if !holding_object:
		return
	if button_name == "trigger_click":
		holding_object.object.use()

func _on_object_detection_area_entered(area: Area3D) -> void:
	if !area is GrabbableArea:
		return
	
	grabbables_in_area.append(area as GrabbableArea)

func _on_object_detection_area_exited(area: Area3D) -> void:
	if !area is GrabbableArea:
		return
	
	grabbables_in_area.remove_at(grabbables_in_area.find(area as GrabbableArea))

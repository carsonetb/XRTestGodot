class_name HandModel
extends Node3D

@onready var thumb: AnimationPlayer = $ThumbAnimation
@onready var index: AnimationPlayer = $IndexAnimation
@onready var middle: AnimationPlayer = $MiddleAnimation
@onready var ring: AnimationPlayer = $RingAnimation
@onready var pinky: AnimationPlayer = $PinkyAnimation

func _ready() -> void:
	thumb.play("thumb")
	index.play("index")
	middle.play("middle")
	ring.play("ring")
	pinky.play("pinky")
	thumb.pause()
	index.pause()
	middle.pause()
	ring.pause()
	pinky.pause()

func set_thumb(amm: float) -> void:
	thumb.seek(amm, true)

func set_index(amm: float) -> void:
	index.seek(amm, true)

func set_grip(amm: float) -> void:
	middle.seek(amm, true)
	ring.seek(amm, true)
	pinky.seek(amm, true)

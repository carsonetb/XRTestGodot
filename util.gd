class_name Util

static func euler_angle_diff(a: Vector3, b: Vector3) -> Vector3:
	var a_quat: Quaternion = Quaternion.from_euler(a)
	var b_quat: Quaternion = Quaternion.from_euler(b)
	var rot: Quaternion = b_quat * a_quat.inverse()
	return rot.get_euler()

static func deadzone(dir: float, deadzone: float) -> float:
	if abs(dir) < deadzone:
		return 0
	else:
		if dir > 0:
			return lerpf(deadzone, 1, dir)
		if dir < 0:
			return lerpf(-deadzone, -1, abs(dir))
	return 0

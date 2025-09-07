class_name Util

static func euler_angle_diff(a: Vector3, b: Vector3) -> Vector3:
	var a_quat: Quaternion = Quaternion.from_euler(a)
	var b_quat: Quaternion = Quaternion.from_euler(b)
	var rot: Quaternion = b_quat * a_quat.inverse()
	return rot.get_euler()

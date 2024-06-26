extends Node

func _ready() -> void:
	
	var arr: Array[Test.TestRes] = []
	print(arr.is_typed())
	print(str(arr.get_typed_script() is Test.TestRes))
	
	return
	var tr: Test.TestRes = Test.TestRes.new()
	tr.ffloat = 4.20
	tr.iint = 69
	tr.str = "hello!"
	tr.vec2 = Vector2(1.0,2.0)
	tr.vec3 = Vector3(4.0,5.0,6.0)
	
	var parsed: String = JSON.stringify({
		"ffloat": tr.ffloat,
		"iint": tr.iint,
		"str": tr.str,
		"vec2": tr.vec2,
		"vec3": tr.vec3,
		"tr": tr
	})
	print(parsed)
	
	var loaded = JSON.parse_string(parsed)
	print(typeof(loaded))
	print(typeof(loaded.vec3))

extends Node

func _ready() -> void:
	var tr: Test.TestRes = Test.TestRes.new()
	tr.ffloat = 4.20
	tr.iint = 69
	tr.str = "hello!"
	tr.vec2 = Vector2(1.0,2.0)
	tr.vec3 = Vector3(4.0,5.0,6.0)
	
	tr.sub_resource = Test.TestRes.new()
	tr.sub_resource.ffloat = 6.9420
	tr.sub_resource.str = "this is a nested object!"
	
	var struct: Dictionary = {
		"ffloat": null,
		"iint": null,
		"str": null,
		"vec2": null,
		"vec3": null,
		"sub_resource": {
			"ffloat": null,
			"str": null,
		}
	}
	
	print(JSONSerialization.serialize_object(tr, struct))

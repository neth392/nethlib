extends Node

func _ready() -> void:
	var test: ObjectJSONSerializer = null
	
	var arr: Array[TestJSONObject] = []
	print(arr.is_typed())
	var script: Script = arr.get_typed_script() as Script
	print(script.get_instance_base_type())
	
	
	#var tr: Test.TestRes = Test.TestRes.new()
	#tr.ffloat = 4.20
	#tr.iint = 69
	#tr.str = "hello!"
	#tr.vec2 = Vector2(1.0,2.0)
	#tr.vec3 = Vector3(4.0,5.0,6.0)
	
	#tr.sub_resource = Test.TestRes.new()
	#tr.sub_resource.ffloat = 6.9420
	#tr.sub_resource.str = "this is a nested object!"
	#
	#print("sub_resource2" in tr)

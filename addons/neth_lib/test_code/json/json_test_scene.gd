extends Node


func _ready() -> void:
	
	var test: JSONTestObject = JSONTestObject.new()
	test.color = Color(0.3, 0.3, 0.2, 0.99)
	test.vec2 = Vector2(6.0, 9.0)
	test.vec3 = Vector3(1.0, 2.0, 3.0)
	test.str = "i been srlized"
	test.str_dont_serialize = "dont seriliz me :)"
	test.iint = 55555
	test.ffloat = 9.12345678
	test.generic_array = [1, 5.3, "hi!", "hello!"]
	
	var sub_object = JSONTestObject.new()
	sub_object.str = "im a sub object"
	sub_object.ffloat = 21.5
	sub_object.iint = 12
	
	test.typed_array = [sub_object, sub_object, sub_object]
	
	#test.sub_object.color = Color(0.555,0.420,0.392,.392)
	#test.sub_object.vec2 = Vector2(24.0, 14.0)
	#test.sub_object.vec3 = Vector3(-1.0, -2.0, -3.0)
	#test.str = "Sub object string!"
	
	JSONSerialization.add_serializer(JSONTestObject.Serializer.new())
	var json: String = JSONSerialization.stringify(test)
	print(json)
	print("")
	
	var new_test: JSONTestObject = JSONTestObject.new()
	JSONSerialization.parse_into(new_test, json)
	print(new_test)
	
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

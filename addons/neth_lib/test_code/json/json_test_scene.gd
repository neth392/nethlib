extends Node

var times: Array[float] = []

func _ready() -> void:
	
	JSONSerialization.add_serializer(JSONTestObject.Serializer.new())
	
	for i in 100:
		_test()
	
	var sum: float = times.reduce(func(a, n): return a + n, 0)
	print("Average Time: " + str(sum / (times.size() as float)))
	
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


func _test() -> void:
	var test: JSONTestObject = JSONTestObject.new()
	test.color = Color(0.3, 0.3, 0.2, 0.99)
	test.vec2 = Vector2(6.0, 9.0)
	test.vec3 = Vector3(1.0, 2.0, 3.0)
	test.str = "i been srlized"
	test.str_dont_serialize = "dont seriliz me :)"
	test.iint = 55555
	test.ffloat = 9.12345678
	test.generic_array = [1, 5.3, "hi!", "hello!"]
	test.dictionary = {
		1: "uno",
		2: "dos",
		"some_key": 55,
		0.001: Vector3(2.0, 3.0, 6.0),
	}
	
	#test.sub_object.color = Color(0.555,0.420,0.392,.392)
	#test.sub_object.vec2 = Vector2(24.0, 14.0)
	#test.sub_object.vec3 = Vector3(-1.0, -2.0, -3.0)
	#test.str = "Sub object string!"
	
	var time = Time.get_ticks_msec()
	#print(test)
	var json: String = JSONSerialization.stringify(test)
	#print(json)
	
	var new_test: JSONTestObject = JSONTestObject.new()
	JSONSerialization.parse_into(new_test, json)
	#print(new_test)
	var end: float = Time.get_ticks_msec()
	times.append((end - time) as float)

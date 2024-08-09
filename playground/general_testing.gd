extends Node


func _ready() -> void:
	var iterations: int = 100000
	
	var objs: Array[TestObject] = []
	for i: int in iterations:
		if i % 2 == 0:
			objs.append(TestObjectTypeA.new())
		else:
			objs.append(TestObjectTypeB.new())
	
	ExecutionTimeTest.start()
	for i: int in iterations:
		var obj: TestObject = objs[i]
		if obj is TestObjectTypeA:
			var d: int = 1
		elif obj is TestObjectTypeB:
			var d: int = 1
	ExecutionTimeTest.print_time_taken("type cast check")
	
	var objs2: Array[TestObjectTyped] = []
	for i: int in iterations:
		if i % 2 == 0:
			objs2.append(TestObjectTyped.new(TestObjectTyped.Type.ONE))
		else:
			objs2.append(TestObjectTyped.new(TestObjectTyped.Type.TWO))
	
	ExecutionTimeTest.start()
	for i: int in iterations:
		var obj: TestObjectTyped = objs2[i]
		match obj.type:
			TestObjectTyped.Type.ONE:
				var d: int = 1
			TestObjectTyped.Type.TWO:
				var d: int = 1
	ExecutionTimeTest.print_time_taken("type enum")


class TestObject:
	var a: String = "hi!"


class TestObjectTypeA extends TestObject:
	var b: String = "hi2!"


class TestObjectTypeB extends TestObject:
	var c: String = "hi3!"


class TestObjectTyped:
	enum Type {
		ONE,
		TWO,
	}
	
	var type: Type
	
	func _init(_type: Type) -> void:
		type = _type

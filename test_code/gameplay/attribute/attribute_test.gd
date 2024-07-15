extends Node


@onready var ac: AttributeContainer = $AttributeContainer

func _ready() -> void:
	
	var h: WrappedAttribute = ac.get_attribute("health")
	var min: Attribute = ac.get_attribute("min_health")
	var max: Attribute = ac.get_attribute("max_health")
	
	h.value_changed.connect(_v_c)
	
	print("h.value: %s" % h.value)
	
	h.value += 50
	print("h.value+=50: %s" % h.value)
	print("")
	h.value += 75
	print("h.value+=75: %s" % h.value)
	print("")
	h.value -= 125
	print("h.value-=125: %s" % h.value)
	print("")
	
	max.value = 200
	print("max.value=200: %s" % max.value)
	print("")
	h.value += 150
	print("h.value+=150: %s" % h.value)
	print("")


func _v_c(old_v: float) -> void:
	print("value_changed: old_value=%s" % old_v)

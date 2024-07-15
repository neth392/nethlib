extends Node


@onready var ac: AttributeContainer = $AttributeContainer
@onready var h: WrappedAttribute = ac.get_attribute("health") as WrappedAttribute

func _ready() -> void:
	
	var min: Attribute = ac.get_attribute("min_health")
	var min2: Attribute = ac.get_attribute("min_health2")
	var max: Attribute = ac.get_attribute("max_health")
	var max2: Attribute = ac.get_attribute("max_health2")
	
	h.value_changed.connect(_v_c)
	h.maximum_value_changed.connect(_max_c)
	h.minimum_value_changed.connect(_min_c)
	
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
	
	h.value += 250
	print("h.value+=250: %s" % h.value)
	print("")
	
	max.value = 200
	print("max.value=200: %s" % max.value)
	print("")
	
	h.value += 150
	print("h.value+=150: %s" % h.value)
	print("")
	
	h.maximum = max2
	print("h.maximum=max2(%s)" % max2.value)
	
	h.value -= 500
	print("h.value-=500: %s" % h.value)
	print("")
	
	h.minimum = min2
	print("h.maximum=min2(%s)" % min2.value)


func _v_c(old_v: float) -> void:
	print("value_changed: new_value=%s, old_value=%s" % [h.value, old_v])


func _max_c(had_old_maximum: bool, old_maximum: float, autowrap_after: BoolRef) -> void:
	print("maximum_value_changed: had_old_maximum=%s, old_maximum=%s, autowrap_after=%s" \
	% [had_old_maximum, old_maximum, autowrap_after.value])


func _min_c(had_old_minimum: bool, old_minimum: float, autowrap_after: BoolRef) -> void:
	print("minimum_value_changed: had_old_minimum=%s, old_minimum=%s, autowrap_after=%s" \
	% [had_old_minimum, old_minimum, autowrap_after.value])

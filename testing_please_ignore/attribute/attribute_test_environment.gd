extends CanvasLayer

var _time_msec: float

@export var container: AttributeContainer
@export var attr: Attribute

@export var attr_label: Label

func _ready() -> void:
	_time_msec = Time.get_ticks_msec() / 1000.0
	container.attribute_added.connect(_on_c_a_a)
	container.attribute_removed.connect(_on_c_a_r)
	container.tag_added.connect(_on_c_t_a)
	container.tag_removed.connect(_on_c_t_r)
	
	attr.base_value_changed.connect(_on_b_v_c)
	attr.current_value_changed.connect(_on_c_v_c)
	attr.effect_added.connect(_on_e_add)
	attr.effect_add_blocked.connect(_on_e_add_blocked)
	attr.effect_applied.connect(_on_e_apply)
	attr.effect_apply_blocked.connect(_on_e_apply_blocked)
	attr.effect_removed.connect(_on_e_removed)
	attr.effect_stack_count_changed.connect(_on_e_stack_count_changed)
	
	attr_label.text = attr_label.text % attr.id
	
	_print("ATTRIBUTE BASE_VALUE: %s" % attr.get_base_value())
	_print("ATTRIBUTE CURRENT_VALUE: %s" % attr.get_current_value())
	
	_print(" ")
	_print("APPLY 2 DAMAGE/SEC OVER 5 SEC")
	
	await get_tree().create_timer(2.0).timeout
	var effect2: AttributeEffect = load("res://testing_please_ignore/attribute/2_damage_sec_over_5_sec.tres") as AttributeEffect
	attr.add_effect(effect2)
	#var total_attributes: int = 1
	#var total_effects: int = 1
	#
	#for i in total_attributes:
		#var new_attr: Attribute = attr.duplicate(DUPLICATE_USE_INSTANTIATION) as Attribute
		#new_attr.name = "HealthAttribute%s" % i
		#new_attr.id = "health%s" % i
		#container.add_child(new_attr)
		#for d in total_effects:
			#var spec: AttributeEffectSpec = effect2.to_spec()
			#new_attr.add_spec(spec)


func _print(str: String) -> void:
	print(str((Time.get_ticks_msec() / 1000.0) - _time_msec) +"s: " + str)
	pass


func _on_c_a_a(a: Attribute) -> void:
	_print("container.attribute_added: attribute=%s" % a)


func _on_c_a_r(a: Attribute) -> void:
	_print("container.attribute_removed: attribute=%s" % a)


func _on_c_t_a(t: StringName) -> void:
	_print("container.tag_added: tag=%s" % t)


func _on_c_t_r(t: StringName) -> void:
	_print("container.tag_removed: tag=%s" % t)


func _on_b_v_c(prev: float) -> void:
	_print("base_value_changed: new=%s, prev=%s" % [attr.get_base_value(), prev])


func _on_c_v_c(prev: float) -> void:
	_print("current_value_changed: new=%s, prev=%s" % [attr.get_current_value(), prev])


func _on_e_add(spec: AttributeEffectSpec) -> void:
	_print("effect_added: spec=%s" % spec)


func _on_e_add_blocked(spec: AttributeEffectSpec) -> void:
	_print("effect_add_blocked: spec=%s" % spec)


func _on_e_apply(spec: AttributeEffectSpec) -> void:
	_print("effect_applied: spec=%s" % spec)


func _on_e_apply_blocked(spec: AttributeEffectSpec) -> void:
	_print("effect_apply_blocked: spec=%s" % spec)


func _on_e_removed(spec: AttributeEffectSpec) -> void:
	_print("effect_removed: spec=%s, active_duration=%s, total_duration=%s, apply_count=%s" \
	% [spec, spec.get_active_duration(), spec.get_total_duration(), spec.get_apply_count()])


func _on_e_stack_count_changed(spec: AttributeEffectSpec, prev_stack_count: int) -> void:
	_print("effect_removed: spec=%s, prev_stack_count=%s" % [spec, prev_stack_count])

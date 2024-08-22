extends CanvasLayer

var _time_msec: float

@export var container: AttributeContainer
@export var attr: Attribute

@export var attr_label: Label

@export var history: AttributeHistory

func _ready() -> void:
	_time_msec = Time.get_ticks_msec() / 1000.0
	container.attribute_added.connect(_on_c_a_a)
	container.attribute_removed.connect(_on_c_a_r)
	container.tag_added.connect(_on_c_t_a)
	container.tag_removed.connect(_on_c_t_r)
	
	attr.base_value_changed.connect(_on_b_v_c)
	attr.current_value_changed.connect(_on_c_v_c)
	attr.spec_added.connect(_on_s_add)
	attr.permanent_spec_applied.connect(_on_p_s_apply)
	attr.spec_apply_blocked.connect(_on_s_apply_blocked)
	attr.spec_add_blocked.connect(_on_s_add_blocked)
	attr.spec_removed.connect(_on_s_removed)
	attr.spec_stack_count_changed.connect(_on_s_stack_count_changed)
	
	attr_label.text = attr_label.text % attr.id
	
	history.changed.connect(_on_h_c)
	history.length_changed.connect(_on_h_l_c)
	
	attr.set_base_value(50)
	
	_print("ATTRIBUTE BASE_VALUE: %s" % attr.get_base_value())
	_print("ATTRIBUTE CURRENT_VALUE: %s" % attr.get_current_value())
	
	_print(" ")
	_print("APPLY 2 DAMAGE/SEC OVER 5 SEC")
	#
	#var blocker: AttributeEffect = load("res://testing_please_ignore/attribute/test_blocker_effect.tres") \
	#as AttributeEffect
	##attr.add_effect(blocker)
	#
#
	#var effect2: AttributeEffect = load("res://testing_please_ignore/attribute/2_damage_sec_over_5_sec.tres") as AttributeEffect
	##attr.add_effect(effect2)
	##var total_attributes: int = 100
	##var total_effects: int = 1
	##
	##for i in total_attributes:
		##var new_attr: Attribute = attr.duplicate(DUPLICATE_USE_INSTANTIATION) as Attribute
		##new_attr.name = "HealthAttribute%s" % i
		##new_attr.id = "health%s" % i
		##container.add_child(new_attr)
		##for d in total_effects:
			##new_attr.add_effects([effect2, blocker])


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


func _on_b_v_c(prev: float, spec: AttributeEffectSpec) -> void:
	_print("base_value_changed: new=%s, prev=%s, spec=%s" % [attr.get_base_value(), prev, spec])


func _on_c_v_c(prev: float) -> void:
	_print("current_value_changed: new=%s, prev=%s" % [attr.get_current_value(), prev])


func _on_s_add(spec: AttributeEffectSpec) -> void:
	_print("spec_added: spec=%s" % spec)


func _on_p_s_apply(spec: AttributeEffectSpec) -> void:
	_print("spec_applied: spec=%s" % spec)


func _on_s_apply_blocked(spec: AttributeEffectSpec, blocked_by: AttributeEffectSpec) -> void:
	_print("spec_apply_blocked: spec=%s, blocked_by=%s" % [spec, blocked_by])


func _on_s_add_blocked(spec: AttributeEffectSpec, blocked_by: AttributeEffectSpec) -> void:
	_print("spec_add_blocked: spec=%s, blocked_by=%s" % [spec, blocked_by])


func _on_s_removed(spec: AttributeEffectSpec) -> void:
	_print("spec_removed: spec=%s, active_duration=%s, total_duration=%s, apply_count=%s" \
	% [spec, spec.get_active_duration(), spec.get_total_duration(), spec.get_apply_count()])


func _on_s_stack_count_changed(spec: AttributeEffectSpec, prev_stack_count: int) -> void:
	_print("spec_stack_count_changed: spec=%s, prev_stack_count=%s" % [spec, prev_stack_count])


func _on_h_c(added: AttributeEffectSpec, removed: AttributeEffectSpec) -> void:
	_print("history.history_changed: added=%s, remove=%s" % [added, removed])


func _on_h_l_c(previous_length: int, removed: Array[AttributeEffectSpec]) -> void:
	_print("history.lenght_changed, previous_length=%s, remove=%s" % [previous_length, removed])

extends Node

@export var container: AttributeContainer
@export var attr: Attribute


func _ready() -> void:
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
	
	print("ATTRIBUTE BASE_VALUE: %s" % attr.get_base_value())
	print("ATTRIBUTE CURRENT_VALUE: %s" % attr.get_current_value())
	
	print("APPLY EFFECT")
	var effect: AttributeEffect = load("res://test/attribute/damage_effect.tres") as AttributeEffect
	attr.add_effect(effect)
	print("ATTRIBUTE BASE_VALUE: %s" % attr.get_base_value())
	print("ATTRIBUTE CURRENT_VALUE: %s" % attr.get_current_value())


func _on_c_a_a(a: Attribute) -> void:
	print("container.attribute_added: attribute=%s" % a)


func _on_c_a_r(a: Attribute) -> void:
	print("container.attribute_removed: attribute=%s" % a)


func _on_c_t_a(t: StringName) -> void:
	print("container.tag_added: tag=%s" % t)


func _on_c_t_r(t: StringName) -> void:
	print("container.tag_removed: tag=%s" % t)


func _on_b_v_c(prev: float) -> void:
	print("base_value_changed: new=%s, prev=%s" % [attr.get_base_value(), prev])


func _on_c_v_c(prev: float) -> void:
	print("current_value_changed: new=%s, prev=%s" % [attr.get_current_value(), prev])


func _on_e_add(spec: AttributeEffectSpec) -> void:
	print("effect_added: spec=%s" % spec)


func _on_e_add_blocked(spec: AttributeEffectSpec) -> void:
	print("effect_add_blocked: spec=%s" % spec)


func _on_e_apply(spec: AttributeEffectSpec) -> void:
	print("effect_applied: spec=%s" % spec)


func _on_e_apply_blocked(spec: AttributeEffectSpec) -> void:
	print("effect_apply_blocked: spec=%s" % spec)


func _on_e_removed(spec: AttributeEffectSpec) -> void:
	print("effect_removed: spec=%s" % spec)


func _on_e_stack_count_changed(spec: AttributeEffectSpec, prev_stack_count: int) -> void:
	print("effect_removed: spec=%s, prev_stack_count=%s" % [spec, prev_stack_count])

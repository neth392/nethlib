@tool
class_name AttributeUtil extends Object

## Properties that are excluded from the inspector when the 
## [member duration_type] is [enum DurationType.INSTANT].
static var instant_exclusion_props: PackedStringArray = PackedStringArray([
	"minimum",
	"minimum_calc_type",
	"maximum",
	"maximum_calc_type",
	"regen_per_second",
	"regen_per_second_calc_type",
	"regen_delay_seconds",
	"stack_mode",
	"duration_seconds",
	"period_type",
	"period_curve",
	"period_in_seconds",
])


## Properties that are excluded from the inspector when conditions are disabled.
static var condition_properties: PackedStringArray = PackedStringArray([
	"attribute_groups",
	"attribute_owner_groups",
	"attribute_parent_groups",
])

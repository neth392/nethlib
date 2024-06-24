## Exports the single variable [member platform_references].
## Useful for when a list of [Platform]s needs to be exported, as the utility of 
## [PlatformReference] only allows a platform ID to be that of a registered platform.
@tool
class_name PlatformReferenceArray extends Resource

## Array of [PlatformReference]s.
@export var platform_references: Array[PlatformReference] = []:
	set(value):
		platform_references = value if value != null else []


## Constructs and returns a new [PackedStringArray] containing all [member Platform.id]
## from each [PlatformReference] added to [member platform_references].
## If [param exclude_duplicates] is true, duplicates are not added to the returned array.
func get_platform_ids(exclude_duplicates: bool = true) -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for reference: PlatformReference in platform_references:
		if !reference.platform_id.is_empty() \
		and (!exclude_duplicates || !ids.has(reference.platform_id)):
			ids.append(reference.platform_id)
	return ids

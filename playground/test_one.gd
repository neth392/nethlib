class_name DifficultyLayer extends Resource

# The name of the layer, i.e. "Surface"
@export var name: String

@export var min: int
@export var max: int


# Not sure if this is a float, you can change the type.
@export var depth: float

# You had "???" at depth above 1200, so this will represent the depth in the
# string in format_as_text.
@export var depth_string: String

# This can be called on any difficulty layer instance to create & return the
# string you want the player to see. I just copied the string you had already.
func format_as_text() -> String:
	# Notice how much cleaner the string looks using format strings (%s)
	# See https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html
	return "Layer: \n%s\n\nDepth:\n%s" % [name, depth_string]

# This node/scene will manage your layers.
class_name DifficutlyLayerManager extends Node

# This will let you set the layers in the editor
@export var layers: Array[DifficultyLayer]

# Set the layer indicator node in the inspector here. Not sure if it is a label,
# I assume it is from your code. Your current line of "$Side_Buttons/ProgressBar/layer_indicator"
# is inefficient, $NodeName/etc searches the tree every time you use it. By exporting the
# node and setting it in the inspector, you do not have to search the tree every _process call
# (which is very often)
@export var layer_indicator: Label

# Cache the depth value so you dont need to iterate layers every _process call,
# but only if the depth value changes
@onready var _last_depth_value: float = globals.depth_value

func _process(delta: float) -> void:
	# Check if the depth value changed
	if globals.depth_value == _last_depth_value:
		# It didn't don't run any more code, just return
		return
	# The depth_value changed, let's check for layers
	_last_depth_value = globals.depth_value
	
	# Iterate all layers
	for layer: DifficultyLayer in layers:
		# Check if the global.depth_value is within the layer's range
		if globals.depth_value >= layer.min && globals.depth_value <= layer.max:
			layer_indicator.text = layer.format_as_text() # Set the label's text to the layer
			return # Exit the function
	
	# If this portion of the code is reached there is no layer that meets the current globals.depth_value
	print("No layer meets the current depth_value!!")



var globals: Dictionary = {}

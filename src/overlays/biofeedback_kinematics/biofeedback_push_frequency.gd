extends Control

# ---------------------------------------------------------------------- #
# GUI overlay for displaying mean push frequency from biofeedback data
# - receives mean push frequency values from the device Python bridge
# - Displays the current mean push frequency whithin a slider
# ---------------------------------------------------------------------- #

# Slider parameters
@export_category("Slider parameters")
@export var min_value = 0.0
@export var max_value = 2.5

# UI elements
@export_category("Nodes")
@export var node_min_value: Node
@export var node_max_value: Node
@export var node_value: Node
@export var node_slider_zone: Node
@export var node_slider: Node
@export var node_target_zone: Node
@export var node_green_zone: Node

# Push frequency value from python script biofeedback
var current_value = 0.0

# Connection flags and request arguments
var connected = false
var biofeedback_args

## Results from wheelsims_analysis (python) - Updated by parent node
var analysis_results := {}


func _process(_delta) -> void:
	if "right" in analysis_results and "mean_push_frequency" in analysis_results["right"]:
		current_value = analysis_results["right"]["mean_push_frequency"]

	node_min_value.text = str(min_value)
	node_max_value.text = str(max_value)
	node_value.text = str(
		snappedf(Config.get_value("overlays.biofeedback_push_frequency.target_frequency"), 0.1)
	)

	node_slider.position.y = (
		node_slider_zone.size.y
		- (current_value - min_value) * node_slider_zone.size.y / (max_value - min_value)
	)

	node_target_zone.position.y = (
		node_slider_zone.size.y
		- (
			(
				Config.get_value("overlays.biofeedback_push_frequency.target_frequency")
				+ Config.get_value("overlays.biofeedback_push_frequency.green_zone") / 2
			)
			/ (max_value - min_value)
			* node_slider_zone.size.y
		)
	)

	node_green_zone.size.y = (
		Config.get_value("overlays.biofeedback_push_frequency.green_zone")
		/ (max_value - min_value)
		* node_slider_zone.size.y
	)

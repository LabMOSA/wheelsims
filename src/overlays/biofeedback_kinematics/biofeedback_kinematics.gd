extends Node2D

var python_bridge: Node

## Results from wheelsims_analysis/biofeedback_kinematics, updated regularly
var analysis_results: Dictionary


func _ready() -> void:
	await SignalBus.python_bridge_connected
	python_bridge = Globals.main.get_node("PythonBridge")
#	await python_bridge.run("biofeedback_kinematics_connect", {})
	update_loop()


func update_loop() -> void:
	while true:
		var temp

		temp = await (
			python_bridge
			. run(
				"biofeedback_kinematics",
				{
					"coordinates_left_wheel_center":
					Config.get_value("coordinates.left_wheel_center"),
					"coordinates_right_wheel_center":
					Config.get_value("coordinates.right_wheel_center"),
					"coordinates_left_hand": Config.get_value("coordinates.left_hand"),
					"coordinates_right_hand": Config.get_value("coordinates.right_hand"),
					"wheel_diameter": Config.get_value("player.pushrim_diameter"),
				}
			)
		)
		if temp != null:
			analysis_results = temp

		# set local variable analysis_results of every decendent node that has
		# such variable.
		propagate_call("set", ["analysis_results", analysis_results])


func _process(_delta) -> void:
	$BiofeedbackPushPattern.visible = Config.get_value("overlays.biofeedback_push_pattern.enabled")
	$BiofeedbackPushFrequency.visible = Config.get_value(
		"overlays.biofeedback_push_frequency.enabled"
	)

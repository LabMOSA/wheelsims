extends Node2D

var python_bridge: Node

func _ready() -> void:
	await SignalBus.python_bridge_connected
	python_bridge = Globals.main.get_node("PythonBridge")
	await python_bridge.run("biofeedback_kinematics_connect", {})
	update_loop()

func update_loop() -> void:
	#!TODO Call Python and the update functions from both overlays
	pass

extends Node2D

const N_POINTS := 300

var f_tot_curve: Array[float] = []
var python_bridge: Node

@onready var n_answers := 0

## Set FlimitCurve and FlimitValue to a given value.
func _set_f_limit(value:float):
	%FtargetCurve.position.y = -value
	%FtargetValue.text = str(int(value))


func _ready() -> void:
	# Set initial values
	for i in N_POINTS:
		f_tot_curve.append(0.0)
	_set_f_limit(Config.get_value("overlays.biofeedback_pushrim_kinetics.target_force"))
	
	await SignalBus.python_bridge_connected
	python_bridge = Globals.main.get_node("PythonBridge")
	await python_bridge.run("biofeedback_pushrim_kinetics_connect", {"ip": "dummy"})
	update_loop()


func update_loop() -> void:
	while true:
		var result = await python_bridge.run("biofeedback_pushrim_kinetics_process", {})
		var f_peak = str(int(result["Fpeak"]))
		if f_peak == "0":
			f_peak = ""
		%FpeakLabel.text = f_peak
		for i in N_POINTS:
			f_tot_curve[i] = result["FtotCurve"][i]

		var new_points : Array[Vector2] = []
		for i in N_POINTS:
			new_points.append(Vector2(i, -f_tot_curve[i]))
		%FtotCurve.points = PackedVector2Array(new_points)

func _process(_delta) -> void:
	if Config.value_changed("biofeedback_pushrim_kinetics", "overlays.biofeedback_pushrim_kinetics.target_force"):
		_set_f_limit(Config.get_value("overlays.biofeedback_pushrim_kinetics.target_force"))
	if not Config.get_value("overlays.biofeedback_pushrim_kinetics.enabled"):
		queue_free()

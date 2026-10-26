extends GutTest

const SCENES_DIR := "res://playable_scenes"
const RUN_TIME := 0.5

var scene_paths: Array[String] = _find_scenes(SCENES_DIR)


func test_playable_scene(scene_path = use_parameters(scene_paths)) -> void:
	var packed_scene: PackedScene = load(scene_path)

	assert_not_null(packed_scene, "Failed to load scene: %s" % scene_path)

	var scene := packed_scene.instantiate()
	get_tree().root.add_child(scene)

	await get_tree().create_timer(RUN_TIME).timeout

	assert_true(is_instance_valid(scene), "Scene crashed or was freed: %s" % scene_path)

	scene.queue_free()

	# Let queue_free complete before loading the next scene.
	await get_tree().process_frame


func _find_scenes(dir_path: String) -> Array[String]:
	var results: Array[String] = []

	var dir := DirAccess.open(dir_path)
	if dir == null:
		return results

	dir.list_dir_begin()

	var filename := dir.get_next()
	while filename != "":
		var full_path := dir_path.path_join(filename)

		if ".tscn" in filename.to_lower():
			results.append(full_path)

		filename = dir.get_next()

	dir.list_dir_end()

	return results

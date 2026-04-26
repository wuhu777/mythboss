extends Node2D

const INITIAL_LEVEL_PATH := "res://scenes/levels/arena_level.tscn"
const INITIAL_SPAWN_ID := &"start"

@onready var level_root: Node2D = $LevelRoot
@onready var player: CharacterBody2D = $Player

var current_level: Node2D = null
var level_runtime_states := {}

func _ready() -> void:
	player.add_to_group("player")
	change_level(INITIAL_LEVEL_PATH, INITIAL_SPAWN_ID)

func change_level(scene_path: String, spawn_id: StringName) -> void:
	var level_scene := load(scene_path) as PackedScene
	if level_scene == null:
		push_error("Unable to load level scene: %s" % scene_path)
		return

	var next_level := level_scene.instantiate() as Node2D
	if next_level == null:
		push_error("Unable to instantiate level scene: %s" % scene_path)
		return

	var spawn_point := _find_spawn_point_in_level(next_level, spawn_id)
	if spawn_point == null:
		push_error("Unable to find spawn point '%s' in %s" % [String(spawn_id), scene_path])
		next_level.queue_free()
		return

	if current_level != null:
		current_level.queue_free()

	current_level = next_level
	level_root.add_child(current_level)

	if player.has_method("reset_runtime_state"):
		player.reset_runtime_state()
	player.global_position = spawn_point.global_position
	if player.has_method("set_spawn_position"):
		player.set_spawn_position(spawn_point.global_position)

func get_level_runtime_state(level_id: String) -> Dictionary:
	if level_id.is_empty() or not level_runtime_states.has(level_id):
		return {}

	var state: Variant = level_runtime_states[level_id]
	if state is Dictionary:
		return (state as Dictionary).duplicate(true)
	return {}

func set_level_runtime_state(level_id: String, state: Dictionary) -> void:
	if level_id.is_empty():
		return
	if state.is_empty():
		level_runtime_states.erase(level_id)
		return

	level_runtime_states[level_id] = state.duplicate(true)

func _find_spawn_point_in_level(level: Node2D, spawn_id: StringName) -> Marker2D:
	if level == null:
		return null

	var spawn_points := level.get_node_or_null("SpawnPoints")
	if spawn_points == null:
		return null

	return spawn_points.get_node_or_null(NodePath(String(spawn_id))) as Marker2D

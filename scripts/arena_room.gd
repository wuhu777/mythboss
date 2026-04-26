extends Node2D

const LOCKED_PATH_COLOR := Color(0.180392, 0.270588, 0.345098, 1.0)
const UNLOCKED_PATH_COLOR := Color(0.509804, 0.741176, 0.4, 1.0)

@onready var path_door: Area2D = $PathDoor
@onready var door_collision_shape: CollisionShape2D = $PathDoor/CollisionShape2D
@onready var exit_path: Polygon2D = $ExitPath

var remaining_targets := 0
var room_state_id := ""
var defeated_target_names: Array[String] = []

func _ready() -> void:
	room_state_id = _get_room_state_id()
	_apply_saved_state()
	_set_door_locked(remaining_targets > 0)

func _apply_saved_state() -> void:
	remaining_targets = 0
	defeated_target_names.clear()

	var saved_state := _load_room_state()
	var is_cleared := bool(saved_state.get("cleared", false))
	for target_name in saved_state.get("defeated_targets", []):
		defeated_target_names.append(String(target_name))

	_connect_targets(self, is_cleared)

func _connect_targets(root: Node, is_cleared: bool) -> void:
	for child in root.get_children():
		if child.has_signal("defeated"):
			var target_name := String(child.name)
			if is_cleared or defeated_target_names.has(target_name):
				if child.has_method("restore_defeated_state"):
					child.restore_defeated_state()
			else:
				remaining_targets += 1
				child.defeated.connect(_on_target_defeated.bind(target_name))
		_connect_targets(child, is_cleared)

func _on_target_defeated(_target: Node, target_name: String) -> void:
	if not defeated_target_names.has(target_name):
		defeated_target_names.append(target_name)
	remaining_targets = max(remaining_targets - 1, 0)
	_save_room_state(remaining_targets == 0)
	if remaining_targets == 0:
		_set_door_locked(false)

func _load_room_state() -> Dictionary:
	var main_scene := get_tree().current_scene
	if main_scene != null and main_scene.has_method("get_level_runtime_state"):
		return main_scene.get_level_runtime_state(room_state_id)
	return {}

func _save_room_state(is_cleared: bool) -> void:
	var main_scene := get_tree().current_scene
	if main_scene == null or not main_scene.has_method("set_level_runtime_state"):
		return

	main_scene.set_level_runtime_state(
		room_state_id,
		{
			"cleared": is_cleared,
			"defeated_targets": defeated_target_names.duplicate(),
		}
	)

func _get_room_state_id() -> String:
	if not scene_file_path.is_empty():
		return scene_file_path
	return String(name)

func _set_door_locked(is_locked: bool) -> void:
	path_door.monitoring = not is_locked
	door_collision_shape.set_deferred("disabled", is_locked)
	exit_path.color = LOCKED_PATH_COLOR if is_locked else UNLOCKED_PATH_COLOR

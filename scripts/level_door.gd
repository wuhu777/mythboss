extends Area2D

@export_file("*.tscn") var target_scene_path := ""
@export var target_spawn_id: StringName

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if target_scene_path.is_empty():
		return

	var current_scene := get_tree().current_scene
	if current_scene == null or not current_scene.has_method("change_level"):
		return

	current_scene.change_level(target_scene_path, target_spawn_id)

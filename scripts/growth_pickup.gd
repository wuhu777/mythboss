extends Area2D

signal chosen(mutation_id: StringName)

const MUTATION_NONE := &"none"
const MUTATION_BLADE_LIMB := &"blade_limb"
const MUTATION_FAN_ARM := &"fan_arm"
const BLADE_RING_COLOR := Color(0.807843, 0.596078, 0.309804, 1.0)
const FAN_RING_COLOR := Color(0.333333, 0.654902, 0.835294, 1.0)

@export var mutation_id: StringName = MUTATION_BLADE_LIMB

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ring: Polygon2D = $Ring
@onready var core: Polygon2D = $Core
@onready var blade_mark: Line2D = $BladeMark
@onready var fan_mark: Line2D = $FanMark

var is_available := true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_visual_state()
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("get_active_mutation_id") and player.get_active_mutation_id() != MUTATION_NONE:
		deactivate_pickup()

func deactivate_pickup() -> void:
	is_available = false
	monitoring = false
	collision_shape.set_deferred("disabled", true)
	visible = false

func _on_body_entered(body: Node) -> void:
	if not is_available or not body.is_in_group("player"):
		return
	if not body.has_method("apply_mutation"):
		return
	if not body.apply_mutation(mutation_id):
		return

	chosen.emit(mutation_id)
	_deactivate_sibling_pickups()
	deactivate_pickup()

func _deactivate_sibling_pickups() -> void:
	var parent := get_parent()
	if parent == null:
		return
	for sibling in parent.get_children():
		if sibling == self:
			continue
		if sibling.has_method("deactivate_pickup"):
			sibling.deactivate_pickup()

func _apply_visual_state() -> void:
	blade_mark.visible = mutation_id == MUTATION_BLADE_LIMB
	fan_mark.visible = mutation_id == MUTATION_FAN_ARM
	var ring_color := BLADE_RING_COLOR if mutation_id == MUTATION_BLADE_LIMB else FAN_RING_COLOR
	ring.color = ring_color
	core.color = Color(ring_color.r, ring_color.g, ring_color.b, 0.35)
	blade_mark.default_color = Color(0.996078, 0.937255, 0.780392, 1.0)
	fan_mark.default_color = Color(0.905882, 0.972549, 1.0, 1.0)

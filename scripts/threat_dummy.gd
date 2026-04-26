extends Node2D

signal defeated(dummy: Node)

enum ThreatState {
	IDLE,
	WARNING,
	RECOVER,
}

@export var max_health := 3
@export var idle_duration := 1.1
@export var warning_duration := 0.7
@export var recover_duration := 0.8
@export var attack_flash_duration := 0.12
@export var hit_flash_duration := 0.14

const BODY_COLOR := Color(0.631373, 0.270588, 0.25098, 1.0)
const WARNING_COLOR := Color(0.988235, 0.733333, 0.305882, 1.0)
const ATTACK_COLOR := Color(0.94902, 0.321569, 0.282353, 0.75)
const HIT_COLOR := Color(0.972549, 0.862745, 0.509804, 1.0)
const DEFEATED_COLOR := Color(0.360784, 0.392157, 0.435294, 1.0)

@onready var body_visual: Polygon2D = $Body
@onready var telegraph: Polygon2D = $Telegraph
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurtbox_collision_shape: CollisionShape2D = $Hurtbox/CollisionShape2D

var state := ThreatState.IDLE
var state_timer := 0.0
var attack_flash_timer := 0.0
var hit_flash_timer := 0.0
var health := 0
var is_defeated := false

func _ready() -> void:
	assert(hurtbox != null)
	health = max(max_health, 1)
	state_timer = idle_duration
	var attack_shape := attack_collision_shape.shape as CircleShape2D
	if attack_shape != null:
		telegraph.polygon = _build_circle_polygon(attack_shape.radius, 24)
	_update_visuals()

func _physics_process(delta: float) -> void:
	if is_defeated:
		return

	state_timer = max(state_timer - delta, 0.0)
	attack_flash_timer = max(attack_flash_timer - delta, 0.0)
	hit_flash_timer = max(hit_flash_timer - delta, 0.0)

	if state_timer <= 0.0:
		_advance_state()

	_update_visuals()

func receive_attack(_source_position: Vector2) -> bool:
	if is_defeated:
		return false

	health = max(health - 1, 0)
	hit_flash_timer = hit_flash_duration
	if health <= 0:
		_defeat()
		return true

	state = ThreatState.IDLE
	state_timer = idle_duration
	attack_flash_timer = 0.0
	_update_visuals()
	return true

func _advance_state() -> void:
	match state:
		ThreatState.IDLE:
			state = ThreatState.WARNING
			state_timer = warning_duration
		ThreatState.WARNING:
			_strike()
			state = ThreatState.RECOVER
			state_timer = recover_duration
		ThreatState.RECOVER:
			state = ThreatState.IDLE
			state_timer = idle_duration

func _strike() -> void:
	attack_flash_timer = attack_flash_duration
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("receive_hit"):
			body.receive_hit(global_position)

func _defeat(should_emit_signal: bool = true) -> void:
	is_defeated = true
	state_timer = 0.0
	attack_flash_timer = 0.0
	hit_flash_timer = 0.0
	attack_area.monitoring = false
	hurtbox.monitoring = false
	attack_collision_shape.set_deferred("disabled", true)
	hurtbox_collision_shape.set_deferred("disabled", true)
	_update_visuals()
	if should_emit_signal:
		defeated.emit(self)

func restore_defeated_state() -> void:
	if is_defeated:
		return
	_defeat(false)

func _update_visuals() -> void:
	if is_defeated:
		body_visual.color = DEFEATED_COLOR
		telegraph.visible = false
		return

	if hit_flash_timer > 0.0:
		body_visual.color = HIT_COLOR
	else:
		body_visual.color = BODY_COLOR

	if attack_flash_timer > 0.0:
		telegraph.visible = true
		telegraph.color = ATTACK_COLOR
		return

	if state == ThreatState.WARNING:
		telegraph.visible = true
		var pulse := 0.25 + 0.15 * sin(float(Time.get_ticks_msec()) * 0.015)
		telegraph.color = Color(WARNING_COLOR.r, WARNING_COLOR.g, WARNING_COLOR.b, 0.35 + pulse)
	else:
		telegraph.visible = false

func _build_circle_polygon(radius: float, point_count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(point_count):
		var angle := TAU * float(index) / float(point_count)
		points.append(Vector2.RIGHT.rotated(angle) * radius)
	return points

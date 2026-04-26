extends CharacterBody2D

const MOVE_SPEED := 220.0
const DODGE_SPEED := 620.0
const DODGE_DURATION := 0.18
const DODGE_INVULNERABLE_DURATION := 0.12
const DODGE_COOLDOWN := 0.55
const LIGHT_ATTACK_DURATION := 0.14
const LIGHT_ATTACK_COOLDOWN := 0.2
const HEAVY_ATTACK_DURATION := 0.3
const HEAVY_ATTACK_COOLDOWN := 0.42
const ATTACK_SWITCH_GRACE_DURATION := 0.22
const SWITCH_INVULNERABLE_DURATION := 0.08
const HIT_STUN_DURATION := 0.18
const HIT_FLASH_DURATION := 0.15

const ATTACK_TYPE_NONE := &"attack_none"
const ATTACK_TYPE_LIGHT := &"light"
const ATTACK_TYPE_HEAVY := &"heavy"

const MUTATION_NONE := &"none"
const MUTATION_BLADE_LIMB := &"blade_limb"
const MUTATION_FAN_ARM := &"fan_arm"

const DEFAULT_COLOR := Color(0.94902, 0.619608, 0.0862745, 1.0)
const DODGE_COLOR := Color(0.415686, 0.811765, 0.94902, 1.0)
const LIGHT_ATTACK_COLOR := Color(0.972549, 0.862745, 0.509804, 1.0)
const HEAVY_ATTACK_COLOR := Color(0.941176, 0.486275, 0.388235, 1.0)
const HIT_COLOR := Color(0.92549, 0.313726, 0.231373, 1.0)
const BLADE_ATTACK_COLOR := Color(0.968627, 0.905882, 0.627451, 0.95)
const FAN_ATTACK_COLOR := Color(0.772549, 0.886275, 0.984314, 0.95)
const SPEAR_ATTACK_COLOR := Color(0.0, 0.658824, 0.529412, 0.95)
const SCYTHE_ATTACK_COLOR := Color(0.556863, 0.270588, 0.678431, 0.95)

const BASE_LIGHT_ATTACK_AREA_POSITION := Vector2(0, -32)
const BASE_LIGHT_ATTACK_AREA_SIZE := Vector2(44, 28)
const BASE_LIGHT_ATTACK_VISUAL_POSITION := Vector2(0, -22)
const BASE_HEAVY_ATTACK_AREA_POSITION := Vector2(0, -42)
const BASE_HEAVY_ATTACK_AREA_SIZE := Vector2(58, 42)
const BASE_HEAVY_ATTACK_VISUAL_POSITION := Vector2(0, -30)
const BLADE_LIGHT_ATTACK_AREA_POSITION := Vector2(0, -46)
const BLADE_LIGHT_ATTACK_AREA_SIZE := Vector2(52, 42)
const BLADE_LIGHT_ATTACK_VISUAL_POSITION := Vector2(0, -34)
const BLADE_HEAVY_ATTACK_AREA_POSITION := Vector2(0, -58)
const BLADE_HEAVY_ATTACK_AREA_SIZE := Vector2(64, 56)
const BLADE_HEAVY_ATTACK_VISUAL_POSITION := Vector2(0, -44)
const FAN_LIGHT_ATTACK_AREA_POSITION := Vector2(0, -30)
const FAN_LIGHT_ATTACK_AREA_SIZE := Vector2(78, 36)
const FAN_LIGHT_ATTACK_VISUAL_POSITION := Vector2(0, -22)
const FAN_HEAVY_ATTACK_AREA_POSITION := Vector2(0, -36)
const FAN_HEAVY_ATTACK_AREA_SIZE := Vector2(96, 50)
const FAN_HEAVY_ATTACK_VISUAL_POSITION := Vector2(0, -28)
const SPEAR_LIGHT_ATTACK_AREA_POSITION := Vector2(0, -52)
const SPEAR_LIGHT_ATTACK_AREA_SIZE := Vector2(24, 54)
const SPEAR_LIGHT_ATTACK_VISUAL_POSITION := Vector2(0, -38)
const SPEAR_HEAVY_ATTACK_AREA_POSITION := Vector2(0, -68)
const SPEAR_HEAVY_ATTACK_AREA_SIZE := Vector2(28, 68)
const SPEAR_HEAVY_ATTACK_VISUAL_POSITION := Vector2(0, -52)
const SCYTHE_LIGHT_ATTACK_AREA_POSITION := Vector2(0, -28)
const SCYTHE_LIGHT_ATTACK_AREA_SIZE := Vector2(98, 32)
const SCYTHE_LIGHT_ATTACK_VISUAL_POSITION := Vector2(0, -20)
const SCYTHE_HEAVY_ATTACK_AREA_POSITION := Vector2(0, -34)
const SCYTHE_HEAVY_ATTACK_AREA_SIZE := Vector2(120, 44)
const SCYTHE_HEAVY_ATTACK_VISUAL_POSITION := Vector2(0, -26)

const BLADE_TIMING_MULTIPLIER := Vector2(1.0, 1.0)
const FAN_TIMING_MULTIPLIER := Vector2(0.9, 0.9)
const SPEAR_TIMING_MULTIPLIER := Vector2(1.2, 1.3)
const SCYTHE_TIMING_MULTIPLIER := Vector2(0.8, 0.75)

@onready var visual_root: Node2D = $Visual
@onready var visual_lines: Array[Line2D] = [
	$Visual/Head,
	$Visual/Body,
	$Visual/Arms,
	$Visual/LegLeft,
	$Visual/LegRight,
]
@onready var blade_limb_visual: Line2D = $Visual/BladeLimb
@onready var fan_arm_visual: Line2D = $Visual/FanArm
@onready var spear_limb_visual: Line2D = $Visual/SpearLimb
@onready var scythe_claw_visual: Line2D = $Visual/ScytheClaw
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_area: Area2D = $AttackPivot/AttackArea
@onready var attack_collision_shape: CollisionShape2D = $AttackPivot/AttackArea/CollisionShape2D
@onready var attack_visual: Line2D = $AttackPivot/AttackVisual

var spawn_position := Vector2.ZERO
var facing_direction := Vector2.DOWN
var dodge_direction := Vector2.DOWN
var attack_direction := Vector2.DOWN
var active_mutation_id: StringName = MUTATION_NONE
var current_attack_type: StringName = ATTACK_TYPE_NONE
var last_attack_type: StringName = ATTACK_TYPE_NONE

var dodge_timer := 0.0
var dodge_invulnerable_timer := 0.0
var dodge_cooldown_timer := 0.0
var attack_timer := 0.0
var attack_cooldown_timer := 0.0
var attack_switch_grace_timer := 0.0
var switch_invulnerable_timer := 0.0
var hit_stun_timer := 0.0
var hit_flash_timer := 0.0
var attack_hit_targets: Array[Node] = []

func _ready() -> void:
	spawn_position = global_position
	assert(attack_area != null)
	assert(attack_visual != null)
	_apply_attack_profile(ATTACK_TYPE_LIGHT)
	_stop_attack()
	_update_visual()

func _physics_process(delta: float) -> void:
	_tick_timers(delta)

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if not _is_attacking() and input_vector != Vector2.ZERO:
		facing_direction = input_vector.normalized()

	var requested_attack_type := _get_requested_attack_type()
	if _can_start_dodge():
		_start_dodge(input_vector)
	elif _can_start_attack(requested_attack_type):
		_start_attack(input_vector, requested_attack_type)

	if dodge_timer > 0.0:
		velocity = dodge_direction * DODGE_SPEED
	elif hit_stun_timer > 0.0:
		velocity = Vector2.ZERO
	elif attack_timer > 0.0:
		velocity = Vector2.ZERO
		_process_attack_hits()
	else:
		velocity = input_vector * MOVE_SPEED

	move_and_slide()
	_update_visual()

func receive_hit(source_position: Vector2) -> bool:
	if is_invulnerable():
		return false

	global_position = spawn_position
	velocity = Vector2.ZERO
	dodge_timer = 0.0
	dodge_invulnerable_timer = 0.0
	switch_invulnerable_timer = 0.0
	hit_stun_timer = HIT_STUN_DURATION
	hit_flash_timer = HIT_FLASH_DURATION
	_stop_attack()

	var look_direction := spawn_position - source_position
	if look_direction != Vector2.ZERO:
		facing_direction = look_direction.normalized()

	_update_visual()
	return true

func is_invulnerable() -> bool:
	return dodge_invulnerable_timer > 0.0 or switch_invulnerable_timer > 0.0

func set_spawn_position(world_position: Vector2) -> void:
	spawn_position = world_position

func reset_runtime_state() -> void:
	velocity = Vector2.ZERO
	dodge_timer = 0.0
	dodge_invulnerable_timer = 0.0
	dodge_cooldown_timer = 0.0
	attack_cooldown_timer = 0.0
	attack_switch_grace_timer = 0.0
	switch_invulnerable_timer = 0.0
	hit_stun_timer = 0.0
	hit_flash_timer = 0.0
	_stop_attack()

func get_active_mutation_id() -> StringName:
	return active_mutation_id

func apply_mutation(mutation_id: StringName) -> bool:
	if active_mutation_id != MUTATION_NONE:
		return false
	if mutation_id != MUTATION_BLADE_LIMB and mutation_id != MUTATION_FAN_ARM \
		and mutation_id != MUTATION_SPEAR_ARM and mutation_id != MUTATION_SCYTHE_CLAW:
		return false

	active_mutation_id = mutation_id
	_apply_attack_profile(_get_idle_attack_profile_type())
	_update_visual()
	return true

func _apply_attack_profile(attack_type: StringName) -> void:
	var resolved_attack_type := attack_type
	if resolved_attack_type == ATTACK_TYPE_NONE:
		resolved_attack_type = ATTACK_TYPE_LIGHT

	_update_mutation_visuals()
	match resolved_attack_type:
		ATTACK_TYPE_HEAVY:
			_apply_heavy_attack_profile()
		_:
			_apply_light_attack_profile()

func _apply_light_attack_profile() -> void:
	_set_attack_profile(
		BASE_LIGHT_ATTACK_AREA_POSITION,
		BASE_LIGHT_ATTACK_AREA_SIZE,
		BASE_LIGHT_ATTACK_VISUAL_POSITION,
		_build_attack_points([-14.0, 8.0, 0.0, -10.0, 14.0, 8.0])
	)

	match active_mutation_id:
		MUTATION_BLADE_LIMB:
			_set_attack_profile(
				BLADE_LIGHT_ATTACK_AREA_POSITION,
				BLADE_LIGHT_ATTACK_AREA_SIZE,
				BLADE_LIGHT_ATTACK_VISUAL_POSITION,
				_build_attack_points([-12.0, 12.0, 0.0, -18.0, 12.0, 12.0])
			)
		MUTATION_FAN_ARM:
			_set_attack_profile(
				FAN_LIGHT_ATTACK_AREA_POSITION,
				FAN_LIGHT_ATTACK_AREA_SIZE,
				FAN_LIGHT_ATTACK_VISUAL_POSITION,
				_build_attack_points([-28.0, 10.0, -10.0, -6.0, 0.0, -12.0, 10.0, -6.0, 28.0, 10.0])
			)

func _apply_heavy_attack_profile() -> void:
	_set_attack_profile(
		BASE_HEAVY_ATTACK_AREA_POSITION,
		BASE_HEAVY_ATTACK_AREA_SIZE,
		BASE_HEAVY_ATTACK_VISUAL_POSITION,
		_build_attack_points([-18.0, 12.0, 0.0, -22.0, 18.0, 12.0])
	)

	match active_mutation_id:
		MUTATION_BLADE_LIMB:
			_set_attack_profile(
				BLADE_HEAVY_ATTACK_AREA_POSITION,
				BLADE_HEAVY_ATTACK_AREA_SIZE,
				BLADE_HEAVY_ATTACK_VISUAL_POSITION,
				_build_attack_points([-16.0, 16.0, 0.0, -28.0, 16.0, 16.0])
			)
		MUTATION_FAN_ARM:
			_set_attack_profile(
				FAN_HEAVY_ATTACK_AREA_POSITION,
				FAN_HEAVY_ATTACK_AREA_SIZE,
				FAN_HEAVY_ATTACK_VISUAL_POSITION,
				_build_attack_points([-34.0, 14.0, -18.0, -4.0, 0.0, -16.0, 18.0, -4.0, 34.0, 14.0])
			)

func _update_mutation_visuals() -> void:
	blade_limb_visual.visible = active_mutation_id == MUTATION_BLADE_LIMB
	fan_arm_visual.visible = active_mutation_id == MUTATION_FAN_ARM
	spear_limb_visual.visible = active_mutation_id == MUTATION_SPEAR_ARM
	scythe_claw_visual.visible = active_mutation_id == MUTATION_SCYTHE_CLAW

func _build_attack_points(values: Array[float]) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(0, values.size(), 2):
		points.append(Vector2(values[index], values[index + 1]))
	return points

func _set_attack_profile(area_position: Vector2, area_size: Vector2, visual_position: Vector2, visual_points: PackedVector2Array) -> void:
	var attack_shape := attack_collision_shape.shape as RectangleShape2D
	if attack_shape == null:
		return

	attack_area.position = area_position
	attack_shape.size = area_size
	attack_visual.position = visual_position
	attack_visual.points = visual_points

func _get_requested_attack_type() -> StringName:
	if Input.is_action_just_pressed("heavy_attack"):
		return ATTACK_TYPE_HEAVY
	if Input.is_action_just_pressed("attack"):
		return ATTACK_TYPE_LIGHT
	return ATTACK_TYPE_NONE

func _can_start_dodge() -> bool:
	return hit_stun_timer <= 0.0 and dodge_timer <= 0.0 and attack_timer <= 0.0 and dodge_cooldown_timer <= 0.0 and Input.is_action_just_pressed("dodge")

func _can_start_attack(attack_type: StringName) -> bool:
	return attack_type != ATTACK_TYPE_NONE and hit_stun_timer <= 0.0 and dodge_timer <= 0.0 and attack_timer <= 0.0 and (attack_cooldown_timer <= 0.0 or _can_switch_attack(attack_type))

func _can_switch_attack(attack_type: StringName) -> bool:
	return attack_switch_grace_timer > 0.0 and last_attack_type != ATTACK_TYPE_NONE and attack_type != last_attack_type

func _start_dodge(input_vector: Vector2) -> void:
	var desired_direction := input_vector
	if desired_direction == Vector2.ZERO:
		desired_direction = facing_direction

	dodge_direction = desired_direction.normalized()
	dodge_timer = DODGE_DURATION
	dodge_invulnerable_timer = DODGE_INVULNERABLE_DURATION
	dodge_cooldown_timer = DODGE_COOLDOWN
	hit_stun_timer = 0.0
	switch_invulnerable_timer = 0.0
	_stop_attack()

func _start_attack(input_vector: Vector2, attack_type: StringName) -> void:
	var desired_direction := input_vector
	if desired_direction == Vector2.ZERO:
		desired_direction = facing_direction

	if _can_switch_attack(attack_type):
		switch_invulnerable_timer = SWITCH_INVULNERABLE_DURATION
	else:
		switch_invulnerable_timer = 0.0

	attack_switch_grace_timer = 0.0
	attack_direction = desired_direction.normalized()
	facing_direction = attack_direction
	current_attack_type = attack_type
	_apply_attack_profile(attack_type)
	attack_timer = _get_attack_duration(attack_type)
	attack_cooldown_timer = _get_attack_cooldown(attack_type)
	attack_hit_targets.clear()
	attack_pivot.rotation = attack_direction.angle() + PI / 2.0
	attack_area.monitoring = true
	attack_visual.visible = true

func _get_attack_duration(attack_type: StringName) -> float:
	if attack_type == ATTACK_TYPE_HEAVY:
		return HEAVY_ATTACK_DURATION
	return LIGHT_ATTACK_DURATION

func _get_attack_cooldown(attack_type: StringName) -> float:
	if attack_type == ATTACK_TYPE_HEAVY:
		return HEAVY_ATTACK_COOLDOWN
	return LIGHT_ATTACK_COOLDOWN

func _get_idle_attack_profile_type() -> StringName:
	if current_attack_type != ATTACK_TYPE_NONE:
		return current_attack_type
	return ATTACK_TYPE_LIGHT

func _stop_attack(open_switch_window: bool = false) -> void:
	if open_switch_window and current_attack_type != ATTACK_TYPE_NONE:
		last_attack_type = current_attack_type
		attack_switch_grace_timer = ATTACK_SWITCH_GRACE_DURATION
	else:
		last_attack_type = ATTACK_TYPE_NONE
		attack_switch_grace_timer = 0.0

	attack_timer = 0.0
	attack_area.monitoring = false
	attack_visual.visible = false
	attack_hit_targets.clear()
	current_attack_type = ATTACK_TYPE_NONE
	_apply_attack_profile(ATTACK_TYPE_LIGHT)

func _is_attacking() -> bool:
	return attack_timer > 0.0

func _process_attack_hits() -> void:
	for area in attack_area.get_overlapping_areas():
		var target := area.get_parent()
		if target == null or attack_hit_targets.has(target):
			continue
		if target.has_method("receive_attack"):
			target.receive_attack(global_position)
			attack_hit_targets.append(target)

func _tick_timers(delta: float) -> void:
	dodge_timer = max(dodge_timer - delta, 0.0)
	dodge_invulnerable_timer = max(dodge_invulnerable_timer - delta, 0.0)
	dodge_cooldown_timer = max(dodge_cooldown_timer - delta, 0.0)
	attack_cooldown_timer = max(attack_cooldown_timer - delta, 0.0)
	attack_switch_grace_timer = max(attack_switch_grace_timer - delta, 0.0)
	switch_invulnerable_timer = max(switch_invulnerable_timer - delta, 0.0)
	hit_stun_timer = max(hit_stun_timer - delta, 0.0)
	hit_flash_timer = max(hit_flash_timer - delta, 0.0)

	if attack_timer > 0.0:
		attack_timer = max(attack_timer - delta, 0.0)
		if attack_timer <= 0.0:
			_stop_attack(true)

func _update_visual() -> void:
	var visual_color := DEFAULT_COLOR
	if hit_flash_timer > 0.0:
		visual_color = HIT_COLOR
	elif attack_timer > 0.0:
		visual_color = HEAVY_ATTACK_COLOR if current_attack_type == ATTACK_TYPE_HEAVY else LIGHT_ATTACK_COLOR
	elif dodge_timer > 0.0 or switch_invulnerable_timer > 0.0:
		visual_color = DODGE_COLOR

	for visual_line in visual_lines:
		visual_line.default_color = visual_color

	blade_limb_visual.default_color = visual_color
	fan_arm_visual.default_color = visual_color

	if current_attack_type == ATTACK_TYPE_HEAVY:
		attack_visual.default_color = HEAVY_ATTACK_COLOR
	else:
		match active_mutation_id:
			MUTATION_BLADE_LIMB:
				attack_visual.default_color = BLADE_ATTACK_COLOR
			MUTATION_FAN_ARM:
				attack_visual.default_color = FAN_ATTACK_COLOR
			_:
				attack_visual.default_color = LIGHT_ATTACK_COLOR

	visual_root.rotation = facing_direction.angle() + PI / 2.0

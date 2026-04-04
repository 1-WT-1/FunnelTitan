tool
extends Node2D

export(float, 0, 1) var editor_open = 0.0 setget set_editor_open

export var command = "x"
export var openTime = 1.0
export var powerScale = 0.1

var open = 0.0
var target = 0.0
var direction = 0.0
var ship
var enabled = true
export var openLimit = 0.1

export var systemName = "SYSTEM_FUNNEL_GRINDERS"
export(NodePath) var grinder1
export(NodePath) var grinder2
export(NodePath) var arm1
export(NodePath) var arm2

export var registerExternal = false

export var restDistance = 43.0
export var openDistance = 56.0
export var distanceLimit = 5.0

onready var grinder1node = get_node(grinder1) if grinder1 else null
onready var grinder2node = get_node(grinder2) if grinder2 else null

onready var arm1node = get_node(arm1) if arm1 else null
onready var arm2node = get_node(arm2) if arm2 else null

export var avWorkPitch = 10
export var spinPitchFactor = 45

export var grinderTorque = 60000
export var closeTorque = 500000

onready var openNode = $Open
onready var closeNode = $Close
onready var workNode = $Work

# Captured initial state to support arbitrary tracks/angles
var arm1_home = Vector2.ZERO
var arm1_rel_rot = 0.0
var arm1_dir = Vector2.ZERO

var arm2_home = Vector2.ZERO
var arm2_rel_rot = 0.0
var arm2_dir = Vector2.ZERO

var grinder1_default_damp = -1.0
var grinder2_default_damp = -1.0
var _homes_captured = false

func getStatus():
	return 100
func getPower():
	return open

func _ready():
	_capture_homes()

	if Engine.editor_hint:
		return

	ship = get_parent()
	while ship and not ship.has_method("getConfig"):
		ship = ship.get_parent()

	if registerExternal and ship:
		ship.externalSystems.append(self )

	if ship:
		if arm1node:
			ship.add_collision_exception_with(arm1node)
			if arm1node.has_node("Grinder"):
				ship.add_collision_exception_with(arm1node.get_node("Grinder"))
		if arm2node:
			ship.add_collision_exception_with(arm2node)
			if arm2node.has_node("Grinder"):
				ship.add_collision_exception_with(arm2node.get_node("Grinder"))

func fire(p):
	target = abs(p)
	direction = p

var last = 0
func avFeedback():
	if ship and ship.isPlayerControlled():
		if last < openLimit and open >= openLimit:
			if openNode: openNode.play()
			if workNode: workNode.play()

		if open < openLimit and last >= openLimit:
			if closeNode: closeNode.play()
			if workNode: workNode.stop()

		var rs = 0.0
		if grinder1node and grinder2node:
			rs = (abs(grinder1node.angular_velocity) + abs(grinder2node.angular_velocity)) / 2

		if open > 0:
			if enabled and workNode:
				workNode.pitch_scale = max(avWorkPitch * rs / spinPitchFactor, 0.1)
			elif workNode:
				workNode.pitch_scale = 0.05

	last = open

func _physics_process(delta):
	if not ship or not ship.setup:
		return

	var d = delta / openTime;
	if open >= target:
		open -= d
	else:
		open += d

	avFeedback()
	open = clamp(open, 0.0, 1.0)

	var is_grinding = false
	if open > 0 and enabled and direction != 0:
		var t = open * grinderTorque * delta
		var p = t * powerScale
		if p > 0:
			var pg = ship.drawEnergy(p)
			if pg > 0:
				is_grinding = true
				if grinder1node:
					grinder1node.angular_damp = grinder1_default_damp
					grinder1node.apply_torque_impulse(t * (pg / p) * direction)
				if grinder2node:
					grinder2node.angular_damp = grinder2_default_damp
					grinder2node.apply_torque_impulse(-t * (pg / p) * direction)

	if not is_grinding:
		if grinder1node:
			if abs(grinder1node.angular_velocity) < 1.0:
				grinder1node.angular_velocity = 0.0
				grinder1node.angular_damp = 1000.0
			else:
				grinder1node.angular_damp = grinder1_default_damp
		if grinder2node:
			if abs(grinder2node.angular_velocity) < 1.0:
				grinder2node.angular_velocity = 0.0
				grinder2node.angular_damp = 1000.0
			else:
				grinder2node.angular_damp = grinder2_default_damp

	if Tool.claim(ship):
		if arm1node:
			var target_dist = open * (openDistance - restDistance)
			var current_dist = (arm1node.position - arm1_home).dot(arm1_dir)
			var diff = target_dist - current_dist

			var r1 = arm1node.global_position - ship.global_position
			var arm1_global_dir = arm1_dir.rotated(global_rotation)

			var ship_v1 = ship.linear_velocity + Vector2(-r1.y, r1.x) * ship.angular_velocity
			var dir = arm1_dir.rotated(global_rotation)
			var rel_v = (arm1node.linear_velocity - ship_v1).dot(dir)

			var required_v = diff * 60.0
			var impulse_v = (required_v - rel_v) * arm1node.mass
			var max_force = delta * closeTorque

			var f1 = clamp(impulse_v, -max_force, max_force)
			if (current_dist <= 0.0 and impulse_v > 0) or (current_dist >= (openDistance - restDistance) and impulse_v < 0):
				f1 = impulse_v # Solid metal stops override

			var p = abs(f1 * powerScale * 0.1)
			if p > 0:
				var pd = ship.drawEnergy(p)
				if pd / p > 0.1:
					var fi = f1 * (pd / p)
					arm1node.apply_central_impulse(dir * fi)
					ship.apply_impulse(r1, -dir * fi)

			var rot_error = wrapf((global_rotation + arm1_rel_rot) - arm1node.global_rotation, -PI, PI)
			arm1node.angular_velocity = ship.angular_velocity + (rot_error * 60.0)

		if arm2node:
			var target_dist = open * (openDistance - restDistance)
			var current_dist = (arm2node.position - arm2_home).dot(arm2_dir)
			var diff = target_dist - current_dist

			var r2 = arm2node.global_position - ship.global_position
			var arm2_global_dir = arm2_dir.rotated(global_rotation)

			var ship_v2 = ship.linear_velocity + Vector2(-r2.y, r2.x) * ship.angular_velocity
			var dir = arm2_dir.rotated(global_rotation)
			var rel_v = (arm2node.linear_velocity - ship_v2).dot(dir)

			var required_v = diff * 60.0
			var impulse_v = (required_v - rel_v) * arm2node.mass
			var max_force = delta * closeTorque

			var f2 = clamp(impulse_v, -max_force, max_force)
			if (current_dist <= 0.0 and impulse_v > 0) or (current_dist >= (openDistance - restDistance) and impulse_v < 0):
				f2 = impulse_v # Solid metal stops override

			var p = abs(f2 * powerScale * 0.1)
			if p > 0:
				var pd = ship.drawEnergy(p)
				if pd / p > 0.1:
					var fi = f2 * (pd / p)
					arm2node.apply_central_impulse(dir * fi)
					ship.apply_impulse(r2, -dir * fi)

			var rot_error = wrapf((global_rotation + arm2_rel_rot) - arm2node.global_rotation, -PI, PI)
			arm2node.angular_velocity = ship.angular_velocity + (rot_error * 60.0)

		Tool.release(ship)

func _capture_homes(force = false):
	if _homes_captured and not force:
		return

	var a1 = get_node_or_null(arm1) if arm1 else null
	if a1:
		arm1_home = a1.position
		arm1_rel_rot = a1.rotation
		arm1_dir = Vector2(0, 1).rotated(arm1_rel_rot)

	var a2 = get_node_or_null(arm2) if arm2 else null
	if a2:
		arm2_home = a2.position
		arm2_rel_rot = a2.rotation
		arm2_dir = Vector2(0, 1).rotated(arm2_rel_rot)

	var g1 = get_node_or_null(grinder1) if grinder1 else null
	if g1 and not _homes_captured:
		grinder1_default_damp = g1.angular_damp

	var g2 = get_node_or_null(grinder2) if grinder2 else null
	if g2 and not _homes_captured:
		grinder2_default_damp = g2.angular_damp

	if a1 or a2:
		_homes_captured = true

func set_editor_open(val):
	var is_at_home = (editor_open < 0.05)
	editor_open = val
	open = val

	if Engine.editor_hint:
		if not is_inside_tree():
			return

		_capture_homes(is_at_home)

		var a1 = get_node_or_null(arm1) if arm1 else null
		var a2 = get_node_or_null(arm2) if arm2 else null
		var extension = open * (openDistance - restDistance)

		if a1 and _homes_captured:
			a1.position = arm1_home + (arm1_dir * extension)
		if a2 and _homes_captured:
			a2.position = arm2_home + (arm2_dir * extension)

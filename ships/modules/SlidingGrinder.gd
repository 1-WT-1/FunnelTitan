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

func getStatus():
	return 100
func getPower():
	return open

func _ready():
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

	# Force rotation to be straight
	if arm1node:
		arm1node.global_rotation = global_rotation + PI / 2
		arm1node.angular_velocity = 0.0
	if arm2node:
		arm2node.global_rotation = global_rotation - PI / 2
		arm2node.angular_velocity = 0.0

	var d = delta / openTime;
	if open >= target:
		open -= d
	else:
		open += d
		
	avFeedback()
	open = clamp(open, 0.0, 1.0)
	
	if open > 0 and enabled:
		var t = open * grinderTorque * delta
		var p = t * powerScale
		if p > 0:
			var pg = ship.drawEnergy(p)
			if grinder1node:
				grinder1node.apply_torque_impulse(t * (pg / p) * direction)
			if grinder2node:
				grinder2node.apply_torque_impulse(-t * (pg / p) * direction)

	if Tool.claim(ship):
		if arm1node:
			var target_pos_x = - (restDistance + open * (openDistance - restDistance))
			var diff_x = target_pos_x - arm1node.position.x
			
			var r1 = arm1node.global_position - ship.global_position
			var ship_v1 = ship.linear_velocity + Vector2(-r1.y, r1.x) * ship.angular_velocity
			var rel_v = (arm1node.linear_velocity - ship_v1).dot(Vector2(1, 0).rotated(global_rotation))
			
			var required_v = diff_x * 60.0
			var impulse_v = (required_v - rel_v) * arm1node.mass
			var max_torque = delta * closeTorque
			var f1 = clamp(impulse_v, -max_torque, max_torque)
			
			var p = abs(f1 * powerScale * 0.1)
			if p > 0:
				var pd = ship.drawEnergy(p)
				if pd / p > 0.1:
					var fi = f1 * (pd / p)
					var dir = Vector2(1, 0).rotated(global_rotation)
					arm1node.apply_central_impulse(dir * fi)
					ship.apply_central_impulse(-dir * fi)

		if arm2node:
			var target_pos_x = restDistance + open * (openDistance - restDistance)
			var diff_x = target_pos_x - arm2node.position.x
			
			var r2 = arm2node.global_position - ship.global_position
			var ship_v2 = ship.linear_velocity + Vector2(-r2.y, r2.x) * ship.angular_velocity
			var rel_v = (arm2node.linear_velocity - ship_v2).dot(Vector2(1, 0).rotated(global_rotation))
			
			var required_v = diff_x * 60.0
			var impulse_v = (required_v - rel_v) * arm2node.mass
			var max_torque = delta * closeTorque
			var f2 = clamp(impulse_v, -max_torque, max_torque)
			
			var p = abs(f2 * powerScale * 0.1)
			if p > 0:
				var pd = ship.drawEnergy(p)
				if pd / p > 0.1:
					var fi = f2 * (pd / p)
					var dir = Vector2(1, 0).rotated(global_rotation)
					arm2node.apply_central_impulse(dir * fi)
					ship.apply_central_impulse(-dir * fi)
					
		Tool.release(ship)

func set_editor_open(val):
	editor_open = val
	open = val
	if Engine.editor_hint:
		var a1 = get_node_or_null(arm1) if arm1 else null
		var a2 = get_node_or_null(arm2) if arm2 else null
		if a1:
			a1.position.x = - (restDistance + open * (openDistance - restDistance))
		if a2:
			a2.position.x = restDistance + open * (openDistance - restDistance)

extends Node2D

export var slot = "funnelGrinders"
export var default = "SYSTEM_NONE"
export var command = "x"
export var toggleCommand = ""
var repairFixPrice setget , _getRepairFixPrice
var repairFixTime setget , _getRepairFixTime
var repairReplacementPrice setget , _repairReplacementPrice
var repairReplacementTime setget , _repairReplacementTime


var slotName = slot
var mounted
var enabled = true setget _setEnabled
var mass setget , _getMass
func _getMass():
	if system and "mass" in system:
		return system.mass
	else:
		return 0.0
func getCapacity():
	if system and system.has_method("getCapacity"):
		return system.getCapacity()
	else:
		return 0
	
func getTuneables():
	var system = getSystem()
	if system and system.has_method("getTuneables"):
		var t = system.getTuneables()
		return t
	return {}
	
func fire(p):
	if system and system.has_method("fire"):
		system.fire(p)
		
func getSystem():
	return system

var key
var ship
var system: Node
func _ready():
	ship = get_parent()
	while not ship.has_method("getConfig"):
		ship = ship.get_parent()
	mounted = ship.getConfig(slot)
	if not mounted:
		ship.setConfig(slot, default)
		mounted = default
	
	ship.changeExternalPlaceholders(1)
	Tool.deferCallWhenIdle(self, "loadPlaceholder", [], true)
	
func getShip():
	var c = self
	while not c.has_method("getConfig") and c != null:
		c = c.get_parent()
	return c
func _getRepairFixPrice():
	if system and "repairReplacementTime" in system:
		var s = system.repairFixPrice
		return s
	return 0
	
func _repairReplacementPrice():
	if system and "repairReplacementPrice" in system:
		var s = system.repairReplacementPrice
		return s
	return 0
	
func _getRepairFixTime():
	if system and "repairFixTime" in system:
		var s = system.repairFixTime
		return s
	return 0
	
func _repairReplacementTime():
	if system and "repairReplacementTime" in system:
		var s = system.repairReplacementTime
		return s
	return 0
	
func _setEnabled(how):
	enabled = how
	if system and "enabled" in system:
		system.enabled = how
		
func loadPlaceholder():
	if not is_inside_tree():
		yield(self, "tree_entered")
	key = name + "_" + mounted
	var placeholder = get_node_or_null(mounted)
	if placeholder and placeholder.has_method("replace_by_instance"):
		placeholder.replace_by_instance()
		
	system = get_node_or_null(mounted)
	if system and "systemName" in system:
		system.name = name + "_" + system.name
		system.slotName = slot + "_" + system.systemName
		slotName = system.slotName
	ship.changeExternalPlaceholders( - 1)

func _getSystemName():
	if system and "systemName" in system:
		return system.systemName
	else:
		return "SYSTEM_NONE"
	
func getPower():
	if system and system.has_method("getPower"):
		return system.getPower()
	return 0
	
func getKey():
	if system:
		return system.name
	else:
		return name
	
func getStatus():
	if system:
		if system.has_method("getStatus"):
			return system.getStatus()
	return null
	
func getDamage():
	if system:
		if system.has_method("getDamage"):
			return system.getDamage()
	return {}

func _input(event):
	if toggleCommand and event.is_action_pressed(toggleCommand):
		if Tool.claim(ship):
			if ship.isPlayerControlled() and not ship.cutscene:
				_setEnabled( not enabled)
			Tool.release(ship)


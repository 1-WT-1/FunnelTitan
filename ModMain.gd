extends Node

const MOD_PRIORITY = 0
const MOD_NAME = "Funnel Titan"
const MOD_VERSION_MAJOR = 0
const MOD_VERSION_MINOR = 0
const MOD_VERSION_BUGFIX = 1
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = false

var _savedObjects := []

var modPath: String = get_script().resource_path.get_base_dir() + "/"

func _init(modLoader = ModLoader)
	replaceScene("enceladus/Dealer.tscn")

func _ready():
	l("Ready!")
	
	# Test debug print to verify dealership spawn
	yield (get_tree().create_timer(3.0), "timeout")
	var cg = get_node_or_null("/root/CurrentGame")
	if cg and "modded_ship_list" in cg:
		var found = false
		for ship in cg.modded_ship_list:
			if ship.get("name") == "AT225-CB":
				found = true
				break
		if found:
			l("TEST DEBUG: AT225-CB CAN spawn at the dealership! (Verified in CurrentGame.modded_ship_list)")
		else:
			l("TEST DEBUG ERROR: AT225-CB NOT found in CurrentGame's dealership pool.")
	else:
		l("TEST DEBUG WARNING: Could not find HevLib's CurrentGame extension or modded_ship_list.")
		
func l(msg: String, title: String = MOD_NAME, version: String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
	Debug.l("[%s V%s]: %s" % [title, version, msg])

func replaceScene(newPath: String, oldPath: String = ""):
	l("Updating scene: %s" % newPath)
	if oldPath.empty():
		oldPath = str("res://" + newPath)
	newPath = str(modPath + newPath)
	var scene := load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating: %s" % oldPath)

func installScriptExtension(path: String):
	var childPath: String = str(modPath + path)
	var childScript: Script = ResourceLoader.load(childPath)
	childScript.new()
	var parentScript: Script = childScript.get_base_script()
	var parentPath: String = parentScript.resource_path
	l("Installing script extension: %s <- %s" % [parentPath, childPath])
	childScript.take_over_path(parentPath)

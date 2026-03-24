extends Node

const AT225_CB = {
	"name": "AT225-CB",
	"alias": "AT225",
	"path": "res://FunnelTitan/ships/Charybdis.tscn",
	"used_configs": [],
	"config": {"config": {
		"ammo": {
			"capacity": 1000.0,
			"initial": 1000.0
		},
		"autopilot": {"type": "SYSTEM_AUTOPILOT_MK2"},
		"capacitor": {"capacity": 500.0},
		"cargo": {
			"equipment": "SYSTEM_CARGO_MPUFSO"
		},
		"fuel": {
			"capacity": 80000.0,
			"initial": 80000.0
		},
		"hud": {"type": "SYSTEM_HUD_AT225"},
		"propulsion": {
			"main": "SYSTEM_MAIN_ENGINE_BWMT535",
			"rcs": "SYSTEM_THRUSTER_K37"
		},
		"reactor": {"power": 16.0},
		"turbine": {"power": 500.0},
		"weaponSlot": {
			"middleRight": {"type": "SYSTEM_EMD14"}
		}
	}},
	"dealer": {
		"age": 200,
		"weight": 1
	},
	"derelict": {
		"chance": 0.5,
		"minimum_chance": 0.1,
		"money": 5000000,
		"stock_chance": 0.2,
		"allow_damage": true,
		"cause_extra_damage": true,
		"rock_cluster_chance": 0.3,
		"rock_cluster_count": 33,
		"clump": false,
		"clump_velocity": 25,
		"ring_storm_chance": 0.3,
		"pirate_chance": 0.3,
		"chaos": 0.4
	},
	"miner": {
		"chaos": 0.25
	}
}

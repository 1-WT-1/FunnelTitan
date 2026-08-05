const CHARYBDIS = {
	"ship_name": "SHIP_AT225_CB",
	"modifications": [
		{
			"config": {"id": "FunnelTitan", "section": "FUNNEL_TITAN_CONFIG_SECTION", "entry": "use_main_slots"},
			"path": "weapon-left",
			"property": "remove",
			"value": true
		},
		{
			"config": {"id": "FunnelTitan", "section": "FUNNEL_TITAN_CONFIG_SECTION", "entry": "use_main_slots"},
			"path": "weapon-right",
			"property": "remove",
			"value": true
		},
		{
			"config": {"id": "FunnelTitan", "section": "FUNNEL_TITAN_CONFIG_SECTION", "entry": "use_main_slots", "invert_config": true},
			"path": "weapon-left2",
			"property": "remove",
			"value": true
		},
		{
			"config": {"id": "FunnelTitan", "section": "FUNNEL_TITAN_CONFIG_SECTION", "entry": "use_main_slots", "invert_config": true},
			"path": "weapon-right2",
			"property": "remove",
			"value": true
		}
	]
}

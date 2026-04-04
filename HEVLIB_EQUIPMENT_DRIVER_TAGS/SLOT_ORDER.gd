extends Node

const SLOT_ORDER_RELATIVE = {
	"FunnelGrinderSlot":{
		"relative_to":"CargoBay", # The slot node name or system slot used to position this node relative to.
		"use_node_name":true, # Whether relative_to should use the slot node name or system slot. Defaults to true
		"order_below":false, # Whether this node should be positioned above or below the relative_to slot. Defaults to true
		"entire_group":true, # Whether this should be positioned below just the relative node, or the entire config group. Defaults to true
	}
}

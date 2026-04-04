extends Node2D

export var command = "x"
export var systemName = "SYSTEM_FUNNEL_GRINDERS"
var slotName = name

func fire(p):
	for child in get_children():
		if child.has_method("fire"):
			child.fire(p)

func getStatus():
	return 100
func getPower():
	var p = 0.0
	var children = get_children()
	for child in children:
		if child.has_method("getPower"):
			p += child.getPower()
	p /= children.size()
	return p

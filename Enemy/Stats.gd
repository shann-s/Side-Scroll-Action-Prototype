extends Node


export var max_health = 10
onready var health = max_health setget set_health

signal no_health

func set_health(val):
	health = val
	if health <= 0:
		emit_signal("no_health")

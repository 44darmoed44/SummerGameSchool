extends Node3D

func _ready():
	$item.monitorable = false
	$item.monitoring = false


func enable_monitoring():
	$item.monitorable = true
	$item.monitoring = true


func disable_monitoring():
	$item.set_deferred("monitorable", false)
	$item.set_deferred("monitoring", false)

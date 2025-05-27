extends Node3D

func _ready():
	$item.monitorable = false
	$item.monitoring = false


func enable_monitoring():
	$item.set_deferred("monitorable", true)
	$item.set_deferred("monitoring", true)


func disable_monitoring():
	$item.set_deferred("monitorable", false)
	$item.set_deferred("monitoring", false)

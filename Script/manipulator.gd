extends Node3D

var is_working_with_storage := false
var is_grabbing_item := true
var storage_working: Node3D
var items_node: Node3D
var items_array: Array[Node3D]
@onready var marker := $Armature/Skeleton3D/Marker3D
@onready var animator := $AnimationPlayer
@onready var timer := $Timer

#region build_viewer_script
var elements: Array[MeshInstance3D]
var hit_box: StaticBody3D

var collisions: Array[String]

var shader_color := Color(0.479, 0.902, 0.536, 0.498)
var is_possible_build := true


func _ready():
	for el in get_children():
		match el.get_class():
			"MeshInstance3D":
				elements.append(el)
			"Area3D":
				if el == $HitBox:
					el.connect("body_entered", _on_body_entered)
					el.connect("body_exited", _on_body_exit)
			"StaticBody3D":
				hit_box = el
	set_shader()


func _on_body_entered(body):
	if body == hit_box: return
	collisions.append(body.name)
	shader_color = Color(0.902, 0.143, 0.19, 0.498)
	is_possible_build = false
	change_color()
	

func _on_body_exit(body):
	collisions.erase(body.name)
	if collisions.is_empty():
		shader_color = Color(0.479, 0.902, 0.536, 0.498)
		is_possible_build = true
		change_color()


func set_shader():
	for el in elements:
		var material = ShaderMaterial.new()
		material.shader = load("res://Scenes/main.gdshader")
		el.material_override = material
		el.set_instance_shader_parameter("instance_color_01", shader_color)


func change_color():
	for el in elements:
		el.set_instance_shader_parameter("instance_color_01", shader_color)


func place_object():
	$StateZone.queue_free()
	$Timer.start()
	$WorkSpace.monitoring = true
	for el in elements:
		el.material_override = null
#endregion


func take_item(item):
	if !item.is_inside_tree():
		marker.add_child(item)
		item.scale = Vector3(1, 1, 1)
	else:
		item.reparent(marker)
	item.position = Vector3(0, 0, 0)
	item.disable_monitoring()
	animator.play("transit")
	timer.stop()
	is_grabbing_item = false


func _process(delta):
	if is_working_with_storage and is_grabbing_item:
		if storage_working.storage.size() > 0:
			var item = storage_working.storage[0].duplicate()
			take_item(item)
			storage_working.remove_item(storage_working.storage[0])
	if items_array.size() > 0 and is_grabbing_item:
		var item
		for el in items_array:
			if el != null: 
				item = el
				break
		if item == null: 
			items_array.clear()
			return
		items_array.erase(item)
		take_item(item)


func _on_timer_timeout():
	animator.play("idle")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "idle":
		animator.play("stand")
		timer.start()
	if anim_name == "transit":
		var item = marker.get_child(0)
		item.enable_monitoring()
		item.reparent(items_node)
		is_grabbing_item = true
		if storage_working == null:
			timer.start()
			animator.play("stand")
			timer.start()
		else:
			if storage_working.storage.size() == 0:
				timer.start()


func _on_work_space_area_entered(area):
	match area.name:
		"Area3D":
			var work_building = area.get_parent()
			if work_building.name in ["Drill", "Box", "Combiner"]:
				storage_working = work_building
				is_working_with_storage = true
		"item":
			var item = area.get_parent()
			items_array.append(item)


func _on_work_space_area_exited(area):
	match area.name:
		"Area3D":
			var work_building = area.get_parent()
			if work_building.name in ["Drill", "Box", "Combiner"]:
				is_working_with_storage = false
				storage_working = null
		"item":
			var item = area.get_parent()
			items_array.erase(item)

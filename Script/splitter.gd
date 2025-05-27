extends Node3D

@onready var input_checker := $Input
@onready var output_checkers := $ConveyorCheckers
@onready var timer := $Timer
@onready var outputs: Dictionary = {
	"right" : [null, $ItemSpawners/Right],
	"left" : [null, $ItemSpawners/Left],
	"forward" : [null, $ItemSpawners/Forward]
}

var storage: Array[Node3D]
var item_spawners: Array[Marker3D]
var items_node: Node3D

var current_output := 0

#region build_viewer_sript 
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
	start_check()
	$StateZone.queue_free()
	for el in elements:
		el.material_override = null
#endregion


func start_check():
	for el in output_checkers.get_children():
		el.set_deferred("monitoring", true)


func _on_input_area_entered(area):
	if area.name == "item":
		if item_spawners.size() > 0 and timer.is_stopped(): timer.start()
		var item_ref = area.get_parent()
		storage.append(item_ref.duplicate())
		item_ref.queue_free()


func _process(delta):
	check_outputs_state("delete")


func check_outputs_state(mode):
	match mode:
		"add":
			if !input_checker.monitoring: 
				input_checker.set_deferred("monitoring", true)
			for key in outputs:
				if outputs[key][0] == null or outputs[key][1] in item_spawners: 
					continue
				item_spawners.append(outputs[key][1])
		"delete":
			for key in outputs:
				if outputs[key][0] != null and outputs[key][1] in item_spawners: 
					continue
				item_spawners.erase(outputs[key][1])
			if item_spawners.size() == 0:
				timer.stop()
				input_checker.set_deferred("monitoring", false)


func _on_output_right_area_entered(area):
	if area.name == "ItemTransit" and outputs["right"][0] == null:
		outputs["right"][0] = area.get_parent()
		check_outputs_state("add")


func _on_output_left_area_entered(area):
	if area.name == "ItemTransit" and outputs["left"][0] == null:
		outputs["left"][0] = area.get_parent()
		check_outputs_state("add")


func _on_output_forward_area_entered(area):
	if area.name == "ItemTransit" and outputs["forward"][0] == null:
		outputs["forward"][0] = area.get_parent()
		check_outputs_state("add")


func _on_timer_timeout():
	var item = null
	for el in storage:
		if el != null:
			item = el
			break
	if item == null: 
		storage.clear()
		timer.stop()
		return
	
	items_node.add_child(item)
	item.enable_monitoring()
	item.global_position = item_spawners[current_output].global_position
	storage.erase(item)
	
	if (current_output+1) >= item_spawners.size():
		current_output = 0
	else: current_output += 1

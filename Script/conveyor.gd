extends Node3D

@onready var marker := $Marker3D

var items: Array[Node3D]
var is_placed := false
var rotated_angle := 0

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
	is_placed = true
	for el in elements:
		el.material_override = null
	rotated_angle = round(rad_to_deg(global_rotation.y))
	$ItemTransit.monitoring = true
#endregion


func _on_item_transit_area_entered(area):
	if area.name == "item" and is_placed:
		var item = area.get_parent()
		items.append(item)
		match rotated_angle:
			rotated_angle when rotated_angle == 0 or rotated_angle == -180:
				item.position.x = marker.global_position.x
			rotated_angle when rotated_angle == 90 or rotated_angle == -90:
				item.position.z = marker.global_position.z


func _on_item_transit_area_exited(area):
	if area.name == "item" and is_placed:
		var item = area.get_parent()
		items.erase(item)
		


func _on_timer_timeout():
	for item in items:
		match rotated_angle:
			0:
				item.position.z -= 10 * get_process_delta_time()
			-180:
				item.position.z += 10 * get_process_delta_time()
			90:
				item.position.x -= 10 * get_process_delta_time()
			-90:
				item.position.x += 10 * get_process_delta_time()

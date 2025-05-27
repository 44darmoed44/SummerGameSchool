extends Node3D

@onready var animator := $AnimationPlayer
@onready var product_inst = preload("res://Assets/Models/IronGolem/iron_golem.tscn")

var storage: Array[Node3D]
var components := 0

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
	$Input.set_deferred("monitoring", true)
	for el in elements:
		el.material_override = null
#endregion


func _on_input_area_entered(area):
	if area.name == "item":
		area.get_parent().queue_free()
		components += 1
		if components % 2 == 0: 
			animator.play("work")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "work":
		var product = product_inst.instantiate()
		storage.append(product)
		components -= 2


func remove_item(item):
	storage.erase(item)

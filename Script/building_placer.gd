extends Node3D

@export var buildings_node: Node3D
@export var building_placer: Node3D

var camera: Camera3D
var grid_size := Vector2(0.25, 0.25)
var is_building := false

var raycasted_result: Dictionary
var ray_param: PhysicsRayQueryParameters3D

func _ready():
	camera = get_viewport().get_camera_3d()


func _physics_process(delta):
	place_obj()
	if is_building:
		ray_param.collision_mask = 0b10
	else:
		ray_param.collision_mask = 0b1
	raycasted_result = camera.get_world_3d().get_direct_space_state().intersect_ray(ray_param)
	
	if raycasted_result:
		building_placer.transform.origin = snap_to_grid(raycasted_result.position)


# player input
func _input(event):
	if event.is_action_pressed("rotate") and is_building:
			var build = building_placer.get_children()[0]
			build.rotate_y(deg_to_rad(90))
			
	if event is InputEventKey:
		if !is_building:
			var building_packed: PackedScene
			var build: Node3D
			match event.keycode:
				KEY_1:
					building_packed = load("res://Assets/Models/Conveyor/conveyor.tscn")
				KEY_2:
					building_packed = load("res://Assets/Models/Combiner/combiner.tscn")
				KEY_3:
					building_packed = load("res://Assets/Models/Box/box.tscn")
				KEY_4:
					building_packed = load("res://Assets/Models/Drill/drill.tscn")
				KEY_5:
					building_packed = load("res://Assets/Models/Manipulator/manipulator.tscn")
				KEY_6:
					building_packed = load("res://Assets/Models/Splitter/splitter.tscn")
				_:
					return
			build = building_packed.instantiate()
			
			if build.name == "Manipulator":
				build.items_node = $"../Items"
			if build.name == "Splitter":
				build.items_node = $"../Items"
			
			building_placer.add_child(build)
			is_building = true
			
	if event is InputEventMouseButton:
		if is_building:
			var build = building_placer.get_children()[0]
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if build.is_possible_build:
						build.place_object()
						build.reparent(buildings_node)
					else: return
				MOUSE_BUTTON_RIGHT:
					building_placer.get_children()[0].queue_free()
				_:
					return
			is_building = false
		elif !is_building:
			if event.button_index == MOUSE_BUTTON_RIGHT and !raycasted_result.is_empty():
				if raycasted_result["collider"] == null: return
				raycasted_result["collider"].get_parent().queue_free()
			


#region BuildingPlaycer
func place_obj():
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_from: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_to: Vector3 = ray_from + camera.project_ray_normal(mouse_pos) * 1000
	ray_param = PhysicsRayQueryParameters3D.create(ray_from, ray_to)


func snap_to_grid(pos: Vector3) -> Vector3:
	var snapped_x = round(pos.x / grid_size.x) * grid_size.x
	var snapped_z = round(pos.z / grid_size.y) * grid_size.y
	return Vector3(snapped_x, pos.y, snapped_z)
#endregion

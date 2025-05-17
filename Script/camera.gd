extends Node3D

@onready var camera = self
var rotation_camera

var start: bool = false
var camera_speed = 10
var grid_size := Vector2(1, 1)
var is_rotating: bool = false

func _ready():
	rotation_camera = rotation_degrees.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_camera(delta)
	place_obj()
	#
	#if raycasted_result:
		#cube.transform.origin = snap_to_grid(raycasted_result.position)


func _input(event):
	if Input.is_action_just_released("mouse_left_click"):
		start = true
	zoom_camera(event)
	rotate_camera(event)
	


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			get_viewport().set_input_as_handled()


func snap_to_grid(pos: Vector3) -> Vector3:
	var snapped_x = round(pos.x / grid_size.x) * grid_size.x
	var snapped_z = round(pos.z / grid_size.y) * grid_size.y
	return Vector3(snapped_x, pos.y, snapped_z)


func zoom_camera(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.fov -= 2.5
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.fov += 2.5
	camera.fov = clamp(camera.fov, 50, 75) 
	pass



func rotate_camera(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_rotating = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				is_rotating = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				
	if is_rotating and event is InputEventMouseMotion:
		rotation_camera += event.relative.x * -0.25
		rotation_degrees.y = rotation_camera


func move_camera(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var new_direction = Vector3(direction.x, 0, direction.z) * camera_speed
		camera.position += new_direction * delta


func place_obj():
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	
	var ray_from: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_to: Vector3 = ray_from + camera.project_ray_normal(mouse_pos) * 1000
	var ray_param: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	ray_param.collision_mask = 0b10
	
	var raycasted_result: Variant = camera.get_world_3d().get_direct_space_state().intersect_ray(ray_param)

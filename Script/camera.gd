extends Node3D

@onready var camera = self
var rotation_camera

var camera_speed = 10
var is_rotating: bool = false


func _ready():
	rotation_camera = rotation_degrees.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_camera(delta)


# player input
func _input(event):
	zoom_camera(event)
	rotate_camera(event)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			get_viewport().set_input_as_handled()


func zoom_camera(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.fov -= 2.5
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.fov += 2.5
	camera.fov = clamp(camera.fov, 50, 75) 
	pass


#region CameraController
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
#endregion

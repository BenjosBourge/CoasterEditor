extends Node3D

@export var camera_node : Camera3D
@export var axis_node : Node3D
@export var raycaster_node : RayCast3D
@export var debug_node : Node3D

var node_dragging = null
var node_selected = null

var last_mouse_pos = Vector2.ZERO
var mouse_vector = Vector2.ZERO

var deltatime = 0
var rotation_x = 0
var rotation_y = 0

var is_movement_panning = false
var is_rotation_panning = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if node_dragging != null:
		if node_dragging.has_method("is_dragged"):
			Callable(node_dragging, "is_dragged").call()


func _physics_process(delta):
	deltatime = delta
	var mouse_position = get_viewport().get_mouse_position()
	mouse_vector = mouse_position - last_mouse_pos
	last_mouse_pos = mouse_position
	
	if is_movement_panning:
		transform.origin -= Vector3(transform.basis.x.x, 0, transform.basis.x.z) * mouse_vector.x * delta * 0.8
		transform.origin -= Vector3(transform.basis.z.x, 0, transform.basis.z.z) * mouse_vector.y * delta * 0.8
	
	if is_rotation_panning:
		transform.basis = Basis.IDENTITY
		rotation_x += mouse_vector.x * delta * 0.1
		rotation_y += mouse_vector.y * delta * 0.1
		rotate_x(rotation_y)
		rotate_y(rotation_x)
	
	var start = camera_node.project_ray_origin(mouse_position)
	var end = start + camera_node.project_ray_normal(mouse_position) * 2000
	raycaster_node.transform.origin = start
	raycaster_node.target_position = end
	raycaster_node.force_raycast_update()
	var object = raycaster_node.get_collider()
	if object == null:
		return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed("escape"):
		set_node_selected(null)
	# Mouse in viewport coordinates.
	if event.is_action_pressed("left_click"):
		raycaster_node.collision_mask = 2
		raycaster_node.force_raycast_update()
		var object = raycaster_node.get_collider()
		if object != null and node_selected != null:
			node_dragging = object
			if object.has_method("is_clicked"):
				Callable(object, "is_clicked").call()
			if object.has_method("can_be_selected"):
				if Callable(object, "can_be_selected").call():
					set_node_selected(object)
		else:
			raycaster_node.collision_mask = 1
			raycaster_node.force_raycast_update()
			object = raycaster_node.get_collider()
			if object != null:
				node_dragging = object
				if object.has_method("is_clicked"):
					Callable(object, "is_clicked").call()
				if object.has_method("can_be_selected"):
					if Callable(object, "can_be_selected").call():
						set_node_selected(object)
	if event.is_action_released("left_click"):
		node_dragging = null
	
	if event.is_action_pressed("right_click"):
		is_movement_panning = true
	if event.is_action_released("right_click"):
		is_movement_panning = false
	
	if event.is_action_pressed("middle_click"):
		is_rotation_panning = true
	if event.is_action_released("middle_click"):
		is_rotation_panning = false


func set_node_selected(node):
	if node == null:
		node_selected = null
		axis_node.visible = false
		return
	node_selected = node
	axis_node.visible = true


func pan_axis(start_pos, end_pos):
	var distance = (start_pos - transform.origin).length()
	print(distance)
	var vector = end_pos - start_pos
	var on_screen_start = camera_node.unproject_position(start_pos)
	var on_screen_end = camera_node.unproject_position(end_pos)
	var screen_vector = on_screen_end - on_screen_start
	
	var dot_value = screen_vector.dot(mouse_vector)
	if node_selected != null:
		node_selected.transform.origin += vector * dot_value * deltatime * 0.001 * pow(distance, 1.4)
		axis_node.transform.origin += vector * dot_value * deltatime * 0.001 * pow(distance, 1.4)

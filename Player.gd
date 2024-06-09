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
	if event is InputEventMouseButton:
		if !event.pressed:
			node_dragging = null
			return
		raycaster_node.force_raycast_update()
		var object = raycaster_node.get_collider()
		if object == null:
			return
		node_dragging = object
		if object.has_method("is_clicked"):
			Callable(object, "is_clicked").call()
		if object.has_method("can_be_selected"):
			if Callable(object, "can_be_selected").call():
				set_node_selected(object)


func set_node_selected(node):
	if node == null:
		node_selected = null
		axis_node.visible = false
		return
	node_selected = node
	axis_node.visible = true


func pan_axis(start_pos, end_pos):
	var vector = end_pos - start_pos
	var on_screen_start = camera_node.unproject_position(start_pos)
	var on_screen_end = camera_node.unproject_position(end_pos)
	var screen_vector = on_screen_end - on_screen_start
	
	var dot_value = screen_vector.dot(mouse_vector)
	if node_selected != null:
		node_selected.transform.origin += vector * dot_value * deltatime * 0.01
		axis_node.transform.origin += vector * dot_value * deltatime * 0.01

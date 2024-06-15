extends Node

@export var player_node : Node3D

@export var wagon : Node3D
var wagon_timer = 0
var wagon_launched = false
var speed = 0.1

var step_number = 0
var first_step = null
var last_step = null

var step = preload("res://step.tscn")
var steep = preload("res://steep.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	wagon.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if wagon_launched:
		if wagon_timer < 0:
			wagon_timer = 0
			speed = 0
		var tmp_timer = wagon_timer
		var current_step = first_step
		if current_step == null || current_step.next_step == null:
			return
		while tmp_timer > 1.0:
			tmp_timer -= 1.0
			var old_step = current_step
			current_step = current_step.next_step
			if current_step.next_step == null:
				current_step = old_step
				tmp_timer = 1.0
				speed = 0
				break
		
		var bezier_step_nb = 0
		var in_step_timer = tmp_timer
		while tmp_timer > (1.0 / 11):
			tmp_timer -= (1.0 / 11)
			bezier_step_nb += 1
		
		var bezier_values = bezier([current_step, current_step.post_steep, current_step.next_step.ant_steep, current_step.next_step], in_step_timer)
		
		var start_pos = current_step.transform.origin
		var end_pos = current_step.next_step.transform.origin
		if current_step.rail.size() < 10:
			return
		if bezier_step_nb <= 9:
			end_pos = current_step.rail[bezier_step_nb].transform.origin
		if bezier_step_nb > 0:
			start_pos = current_step.rail[bezier_step_nb - 1].transform.origin
		var distance = (start_pos - end_pos).length()
		wagon.transform.origin = start_pos + (end_pos - start_pos) * tmp_timer * 11
		speed -= bezier_values[1].y / 10
		speed -= speed * 0.98 * delta
		wagon_timer += delta * (speed / distance)


func bezier(steps, value):
	var vectors = []
	var derivative = Vector3.ZERO
	
	for n in steps:
		vectors.push_back(n.transform.origin)
	
	while vectors.size() > 1:
		var new_vectors = []
		
		for i in range(vectors.size() - 1):
			var vector = vectors[i + 1] - vectors[i]
			new_vectors.push_back(vectors[i] + vector * value)
		derivative = (vectors[1] - vectors[0]).normalized()
		vectors = new_vectors
	return [vectors[0], derivative]


func add_step_coaster():
	var s = step.instantiate()
	step_number += 1
	if first_step == null:
		s.transform.origin = Vector3.ZERO
		add_child(s)
		first_step = s
		last_step = s
		player_node.set_node_selected(s)
	else:
		s.transform.origin = last_step.transform.origin
		add_child(s)
		last_step.next_step = s
		last_step = s
		player_node.set_node_selected(s)
	
	var ant_steep = steep.instantiate()
	var post_steep = steep.instantiate()
	add_child(ant_steep)
	add_child(post_steep)
	s.ant_steep = ant_steep
	s.post_steep = post_steep
	ant_steep.my_step = s
	post_steep.my_step = s
	ant_steep.my_other = post_steep
	post_steep.my_other = ant_steep
	ant_steep.transform.origin = s.transform.origin + Vector3(-1, 0, 0)
	post_steep.transform.origin = s.transform.origin + Vector3(1, 0, 0)
	
	
func launch_coaster():
	wagon.visible = true
	wagon_launched = true
	wagon_timer = 0
	speed = 0.5


func stop_coaster():
	wagon.visible = false
	wagon_launched = false

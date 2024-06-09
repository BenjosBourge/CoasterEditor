extends Node

@export var player_node : Node3D

var first_step = null
var last_step = null

var step = preload("res://step.tscn")
var steep = preload("res://steep.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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

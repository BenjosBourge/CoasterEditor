extends StaticBody3D

@export var player_node : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func is_clicked():
	print("Z is clicked")


func is_dragged():
	var start_pos = get_parent().transform.origin
	var end_pos = start_pos + Vector3(0, 0, 1)
	player_node.pan_axis(start_pos, end_pos)

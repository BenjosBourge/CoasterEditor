extends Clickable

var next_step = null
var ant_steep = null
var post_steep = null

var rail = []

var steep_line = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ant_steep != null and post_steep != null:
		if steep_line == null:
			steep_line = MeshInstance3D.new()
			steep_line.mesh = BoxMesh.new()
			steep_line.mesh.size = Vector3(0.1, 0.1, 0.1)
			steep_line.material_override = ant_steep.get_node("Mesh").material_override
			get_parent().add_child(steep_line)
		var vector = (ant_steep.transform.origin - post_steep.transform.origin)
		steep_line.transform.origin = post_steep.transform.origin + vector/2
		steep_line.mesh.size.z = vector.length()
		if steep_line.transform.origin != post_steep.transform.origin:
			steep_line.look_at(post_steep.transform.origin)
		
		if is_selected or ant_steep.is_selected or post_steep.is_selected:
			ant_steep.visible = true
			post_steep.visible = true
			steep_line.visible = true
		else:
			ant_steep.visible = false
			post_steep.visible = false
			steep_line.visible = false
	
	if next_step != null:
		while rail.size() < 10:
			var block = MeshInstance3D.new()
			block.mesh = BoxMesh.new()
			block.mesh.size = Vector3(0.3, 0.3, 0.3)
			rail.append(block)
			get_parent().add_child(block)
		
		var steps = [self, post_steep, next_step.ant_steep, next_step]
		for i in range(10):
			var j = 9 - i
			var bezier = get_parent().bezier(steps, 0.1 * j)
			var bezier3 = get_parent().bezier(steps, 0.1 * j + 0.1)
			var vector = (bezier[0] - bezier3[0])
			rail[j].transform.origin = bezier3[0] + vector/2
			rail[j].mesh.size.z = vector.length()
			if rail[j].transform.origin != bezier3[0]:
				rail[j].look_at(bezier3[0])


func _on_movement(deplacment):
	ant_steep.transform.origin += deplacment
	post_steep.transform.origin += deplacment

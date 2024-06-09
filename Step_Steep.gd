extends Clickable

var my_step = null
var my_other = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func _on_movement(deplacment):
	var a = my_other.transform.origin
	var b = my_step.transform.origin
	var c = transform.origin
	var cb = (b - c).normalized()
	var ba_length = (a - b).length()
	my_other.transform.origin = b + cb * ba_length

extends Area2D

var speed = 1000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.y += -speed * delta

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(1)
		queue_free()

extends Area2D

var speed: float = 400.0
var direction: Vector2 = Vector2.DOWN

func _process(delta):
	global_position += direction * speed * delta
	if global_position.y > get_viewport_rect().size.y + 100:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage(1)
		queue_free()

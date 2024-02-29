extends Area2D

class_name Player
signal spawn_laser(location)
signal killed

@onready var muzzle = $Muzzle 

var speed = 300
var input_vector = Vector2.ZERO
var hp = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	global_position += input_vector * speed * delta
	if Input.is_action_just_pressed("shoot"):
		shoot_laser()
		
	global_position = global_position.clamp(Vector2.ZERO, get_viewport_rect().size)

func take_damage(damage):
	hp -= damage
	if hp <= 0:
		queue_free()
		emit_signal("killed")

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(1)
	
func shoot_laser():
	emit_signal("spawn_laser", muzzle.global_position)
	

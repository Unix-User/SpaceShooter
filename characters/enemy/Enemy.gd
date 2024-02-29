extends Area2D

signal enemy_died

@export var speed:int = 150

var hp = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.y += speed * delta

func take_damage(damage):
	hp -= damage
	if hp <= 0:
		emit_signal("enemy_died")
		queue_free()

func _on_area_entered(area):
	if area is Player:
		area.take_damage(1)

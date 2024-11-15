extends Node2D

var spawn_positions = null
#preload("res://characters/enemy/Enemy.tscn")

# Instead, you can load the resource dynamically:
var enemy_scene = load("res://characters/enemy/Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	spawn_positions = $SpawnPositions.get_children()

	
func spawn_enemy():
	var index = randi() % spawn_positions.size()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_positions[index].global_position
	enemy.connect("enemy_died", Callable(get_tree().current_scene, "_on_enemy_died"))
	add_child(enemy)

func _on_spawn_timer_timeout():
	spawn_enemy()

@warning_ignore("unused_parameter")
func _on_enemy_area_entered(area):
	pass # Replace with function body.

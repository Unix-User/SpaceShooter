extends Node2D

var spawn_positions = null
var Enemy = preload("res://characters/enemy/Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	spawn_positions = $SpawnPositions.get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func spawn_enemy():
	var index = randi() % spawn_positions.size()
	var enemy = Enemy.instantiate()
	enemy.global_position = spawn_positions[index].global_position
	enemy.connect("enemy_died", Callable(get_tree().current_scene, "_on_enemy_died"))
	add_child(enemy)

func _on_spawn_timer_timeout():
	spawn_enemy()


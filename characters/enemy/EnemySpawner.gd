extends Node2D

var spawn_positions = null
var enemy_scene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	spawn_positions = $SpawnPositions.get_children()
	
	# Try to load the enemy scene
	enemy_scene = load("res://characters/enemy/Enemy.tscn")
	if enemy_scene == null:
		push_error("Failed to load enemy scene from: res://characters/enemy/Enemy.tscn")
		# Optionally disable the spawn timer if it exists
		if has_node("SpawnTimer"):
			$SpawnTimer.stop()
	
func spawn_enemy():
	# Check if we have valid spawn positions and enemy scene
	if spawn_positions == null or spawn_positions.size() == 0 or enemy_scene == null:
		push_error("Cannot spawn enemy: Missing required resources")
		return
		
	var index = randi() % spawn_positions.size()
	var enemy = enemy_scene.instantiate()
	if enemy:
		enemy.global_position = spawn_positions[index].global_position
		enemy.connect("enemy_died", Callable(get_tree().current_scene, "_on_enemy_died"))
		add_child(enemy)
	else:
		push_error("Failed to instantiate enemy scene")

func _on_spawn_timer_timeout():
	spawn_enemy()

@warning_ignore("unused_parameter")
func _on_enemy_area_entered(area):
	pass # Replace with function body.

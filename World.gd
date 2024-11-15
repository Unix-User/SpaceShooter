extends Node2D
@onready var pb = $ParallaxBackground
@onready var control = $UiLayer/Control
@onready var game_over_screen = $UiLayer/GameOverScreen

# Store the enemy scene path
const ENEMY_SCENE_PATH = "res://characters/enemy/Enemy.tscn"
var enemy_scene = null

var Laser = preload("res://projectiles/PlayerLaser.tscn")
var score := 0:
	set(value):
		score = value
		control.score = score
var hi_score
var scroll_speed = 100

func _ready():
	# Try to load the enemy scene
	if ResourceLoader.exists(ENEMY_SCENE_PATH):
		enemy_scene = load(ENEMY_SCENE_PATH)
	else:
		push_error("Failed to load enemy scene from: " + ENEMY_SCENE_PATH)
		
	# Load save file
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	if save_file != null:
		hi_score = save_file.get_32()
	else:
		hi_score = 0
		save_game()
	score = 0
	
	# Connect player signals
	var player = $Player
	if player:
		player.connect("killed", Callable(self, "_on_player_killed"))

func save_game():
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(hi_score)

func _on_player_spawn_laser(location):
	var l = Laser.instantiate()
	l.global_position = location
	add_child(l)

func _process(delta):
	pb.scroll_offset.y += delta*scroll_speed
	if pb.scroll_offset.y >= 960:
		pb.scroll_offset.y = 0

func _on_enemy_died():
	score += 10
	if score > hi_score:
		hi_score = score
	
func _on_player_killed():
	game_over_screen.set_score(score)
	game_over_screen.set_hi_score(hi_score)
	save_game()
	await get_tree().create_timer(1.5).timeout
	game_over_screen.visible = true


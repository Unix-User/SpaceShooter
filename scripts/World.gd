extends Node2D

@onready var pb = $ParallaxBackground
@onready var control = $UiLayer/Control
@onready var game_over_screen = $UiLayer/GameOverScreen
@onready var spawner = $EnemySpawner
@onready var spawn_timer = $SpawnTimer

var Laser = preload("res://projectiles/PlayerLaser.tscn")
var score := 0:
	set(value):
		score = value
		control.set_score(score)
var hi_score
var scroll_speed = 100

var generator: LevelGenerator
var seed_fase: int
var dificuldade: float

func _ready():
	# Carrega hi-score
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	if save_file != null:
		hi_score = save_file.get_32()
	else:
		hi_score = 0
		save_game()
	score = 0
	
	var player = $Player
	if player:
		# Desconecta se já estiver conectado (para evitar duplicidade)
		if player.killed.is_connected(_on_player_killed):
			player.killed.disconnect(_on_player_killed)
		player.killed.connect(_on_player_killed)

		if player.health_updated.is_connected(_on_player_health_updated):
			player.health_updated.disconnect(_on_player_health_updated)
		player.health_updated.connect(_on_player_health_updated)
	iniciar_nova_fase()

func save_game():
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(hi_score)

func iniciar_nova_fase():
	seed_fase = randi()
	dificuldade = 1.0
	var screen_size = get_viewport_rect().size
	print("screen_size = ", screen_size)
	generator = LevelGenerator.new()
	generator.iniciar(seed_fase, dificuldade, screen_size)

	spawn_timer.timeout.connect(_spawn_inimigo)
	_spawn_inimigo()  # já spawna o primeiro

func _spawn_inimigo():
	var dados_inimigo = generator.proximo_inimigo()
	spawner.instanciar_inimigos([dados_inimigo])
	
	# Agenda o próximo com base no intervalo da onda
	var intervalo = generator.get_intervalo_proximo_spawn()
	spawn_timer.start(intervalo)

func _on_enemy_died():
	score += 10
	if score > hi_score:
		hi_score = score

func _on_player_killed():
	game_over_screen.set_score(score)
	game_over_screen.set_hi_score(hi_score)
	save_game()
	spawn_timer.stop()
	await get_tree().create_timer(1.5).timeout
	game_over_screen.visible = true

func _on_player_spawn_laser(location):
	var l = Laser.instantiate()
	l.global_position = location
	$LaserSound.play()
	add_child(l)

func _process(delta):
	pb.scroll_offset.y += delta * scroll_speed
	if pb.scroll_offset.y >= 960:
		pb.scroll_offset.y = 0

func _on_player_health_updated(new_health: int):
	control.set_health(new_health)

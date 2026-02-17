extends Node2D

# Carrega a cena do inimigo (ajuste o caminho se necessário)
var enemy_scene = preload("res://characters/enemy/enemy.tscn")

func instanciar_inimigos(dados_inimigos: Array) -> void:
	print("enemy_scene: ", enemy_scene)
	for inimigo_data in dados_inimigos:
		var inimigo = enemy_scene.instantiate()
		inimigo.global_position = Vector2(inimigo_data.pos_x, inimigo_data.pos_y)
		inimigo.initialize(
			inimigo_data.tipo,
			inimigo_data.variante,
			inimigo_data.params
		)
		inimigo.connect("enemy_died", Callable(get_tree().current_scene, "_on_enemy_died"))
		add_child(inimigo)
		

extends Area2D

signal enemy_died

enum Tipo {
	PERSEGUIDOR,   # Black
	LINHA,         # Blue
	FUJAO,         # Green
	ATIRADOR       # Red
}

# Parâmetros básicos
var hp: int = 1
var velocidade_base: float = 100
var tipo: Tipo
var variante: int  # 1 a 5, para ajustes finos
var params: Dictionary  # parâmetros específicos do comportamento

# Referência ao jogador (para perseguição/fuga)
var jogador: Node2D = null

# Variáveis de estado (para comportamentos complexos)
var tempo_vida: float = 0.0
var posicao_inicial: Vector2
var alvo: Vector2
var direcao_atual: Vector2

# Para atiradores
var bullet_scene = preload("res://projectiles/EnemyLaser.tscn")
var tempo_ultimo_tiro: float = 0.0

func _ready():
	add_to_group("enemies")
	jogador = get_tree().get_first_node_in_group("player")

func initialize(tipo_inimigo: int, p_variante: int, p_params: Dictionary):
	tipo = tipo_inimigo
	variante = p_variante
	params = p_params
	posicao_inicial = global_position
	_carregar_textura()
	if tipo == Tipo.FUJAO:
		direcao_atual = Vector2.RIGHT.rotated(randf_range(0, 2*PI))
	# Garante que tipo é válido
	if tipo < 0 or tipo > 3:
		tipo = Tipo.LINHA
		params.velocidade = 60

func _carregar_textura():
	var cor_nome = ["Black", "Blue", "Green", "Red"][tipo]
	var caminho = "res://assets/Enemies/enemy" + cor_nome + str(variante) + ".png"
	var textura = load(caminho)
	if textura:
		$Sprite2D.texture = textura
	else:
		push_error("Textura não encontrada: ", caminho)

func _process(delta):
	tempo_vida += delta
	tempo_ultimo_tiro += delta

	# Aplica movimento conforme tipo
	var moveu = false
	match tipo:
		0: # PERSEGUIDOR
			if jogador:
				var dir = (jogador.global_position - global_position).normalized()
				global_position += dir * params.velocidade * delta
				moveu = true
		1: # LINHA
			var ang = params.get("angulo", 0)
			var dir = Vector2.RIGHT.rotated(ang)
			global_position += dir * params.velocidade * delta
			moveu = true
		2: # FUJAO
			if jogador:
				var dist = global_position.distance_to(jogador.global_position)
				if dist < params.distancia_fuga:
					var dir = (global_position - jogador.global_position).normalized()
					global_position += dir * params.velocidade_fuga * delta
				else:
					direcao_atual = direcao_atual.rotated(randf_range(-0.5, 0.5) * delta)
					global_position += direcao_atual * params.velocidade_erra * delta
				moveu = true
		3: # ATIRADOR
			if global_position.y < params.altura_alvo:
				global_position.y += params.velocidade_aproximacao * delta
			else:
				global_position.y += sin(tempo_vida * 2) * 2 * delta
				if tempo_ultimo_tiro >= params.intervalo_tiro:
					atirar()
					tempo_ultimo_tiro = 0.0
				if tempo_vida > params.tempo_max:
					global_position.y += params.velocidade_saida * delta
			moveu = true
	if not moveu:
		# Fallback: desce
		global_position.y += 50 * delta

	# Remove se sair da tela
	if global_position.y > get_viewport_rect().size.y + 200 or global_position.y < -200:
		queue_free()


func atirar():
	if bullet_scene == null:
		return
	if has_node("LaserSound"):
		$LaserSound.play()
	var bala = bullet_scene.instantiate()
	bala.global_position = global_position + Vector2(0, 10)
	# Pode definir direção diferente conforme params
	if params.has("direcao_tiro"):
		bala.direction = params.direcao_tiro
	get_tree().current_scene.add_child(bala)

func take_damage(damage: int):
	hp -= damage
	if hp <= 0:
		emit_signal("enemy_died")
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage(1)

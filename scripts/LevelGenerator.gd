# LevelGenerator.gd
extends Node
class_name LevelGenerator

var rng = RandomNumberGenerator.new()
var seed_base: int
var dificuldade_base: float
var screen_size: Vector2
var onda_atual: int = 0
var inimigos_restantes_na_onda: int = 0
var config_onda: Dictionary = {}
var cores = ["Black", "Blue", "Green", "Red"]
var cor = cores[rng.randi() % cores.size()]
var variante = rng.randi_range(1, 5)


func iniciar(p_seed: int, p_dificuldade: float, p_screen_size: Vector2):
	seed_base = p_seed
	dificuldade_base = p_dificuldade
	screen_size = p_screen_size
	rng.seed = seed_base
	onda_atual = 0
	_gerar_proxima_onda()

func _gerar_proxima_onda():
	onda_atual += 1
	# Usa a semente base + onda_atual para garantir que cada onda seja diferente mas determinística
	rng.seed = seed_base + onda_atual

	var dificuldade_onda = dificuldade_base * (1.0 + (onda_atual - 1) * 0.2) # +20% por onda

	config_onda = {
		"quantidade": int(5 + onda_atual * 2 + rng.randi_range(-2, 2)), # base 5, aumenta com onda
		"intervalo_base": max(0.3, 1.0 / (1.0 + dificuldade_onda * 0.5)), # fica mais rápido
		"velocidade_min": 0.7,
		"velocidade_max": 1.8,
		"tipos_disponiveis": ["normal"] # depois podemos expandir
	}

	inimigos_restantes_na_onda = config_onda.quantidade
	print("Onda ", onda_atual, " com ", inimigos_restantes_na_onda, " inimigos")

func proximo_inimigo() -> Dictionary:
	if screen_size == Vector2.ZERO:
		screen_size = Vector2(1024, 600)  # valor padrão
	if inimigos_restantes_na_onda <= 0:
		_gerar_proxima_onda()
	var inimigo_index = config_onda.quantidade - inimigos_restantes_na_onda
	rng.seed = seed_base + onda_atual * 1000 + inimigo_index

	# Escolhe a cor (tipo) baseado na onda e no índice para variedade
	# Exemplo: cores em sequência cíclica
	var cores = ["Black", "Blue", "Green", "Red"]
	var indice_cor = (onda_atual + inimigo_index) % cores.size()
	var cor = cores[indice_cor]
	var variante = rng.randi_range(1, 5)

	# Define parâmetros conforme a cor (tipo) e variante
	var tipo = _mapear_cor_para_tipo(cor)
	var params = _gerar_params_para_tipo(tipo, variante)

	var pos_x = rng.randf_range(screen_size.x * 0.1, screen_size.x * 0.9)
	var pos_y = rng.randf_range(-200, -50)

	# velocidade_extra agora é usado como multiplicador global (opcional)
	var velocidade_extra = rng.randf_range(0.8, 1.2)

	inimigos_restantes_na_onda -= 1
	print("Gerando inimigo: tipo=", tipo, " params=", params)

	return {
		"tipo": tipo,           # inteiro
		"variante": variante,
		"params": params,
		"pos_x": pos_x,
		"pos_y": pos_y,
		"velocidade_extra": velocidade_extra
	}

func _mapear_cor_para_tipo(cor: String) -> int:
	match cor:
		"Black": return 0
		"Blue":  return 1
		"Green": return 2
		"Red":   return 3
		_:       return 1  # fallback

func _gerar_params_para_tipo(tipo: int, variante: int) -> Dictionary:
	var params = {}
	match tipo:
		0:  # PERSEGUIDOR
			params.velocidade = 80 + variante * 10
		1:  # LINHA
			params.velocidade = 60 + variante * 8
			params.angulo = variante * 0.2
		2:  # FUJAO
			params.velocidade_fuga = 100 + variante * 15
			params.velocidade_erra = 50 + variante * 5
			params.distancia_fuga = 150
		3:  # ATIRADOR
			params.altura_alvo = screen_size.y * 0.4
			params.velocidade_aproximacao = 50 + variante * 10
			params.intervalo_tiro = 0.5 - variante * 0.05
			params.tempo_max = 5.0
			params.velocidade_saida = 100
	return params

func get_intervalo_proximo_spawn() -> float:
	# Retorna o intervalo até o próximo inimigo dentro da onda
	# Pode variar um pouco para não ficar muito mecânico
	rng.seed = seed_base + onda_atual * 2000 + (config_onda.quantidade - inimigos_restantes_na_onda)
	var variacao = rng.randf_range(0.8, 1.2)
	return config_onda.intervalo_base * variacao

func fim_da_fase() -> bool:
	# Podemos definir um número máximo de ondas ou continuar infinitamente
	return false # infinito por enquanto

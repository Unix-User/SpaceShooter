extends Control

@onready var _score_label = $Score
@onready var _health_label = $HealthLabel   # referência ao novo label

func _ready():
	set_score(0)
	set_health(3)

func set_score(new_score: int):
	_score_label.text = "SCORE: " + str(new_score)
	print("Pontuação atualizada para: ", new_score)

func set_health(new_health: int):
	_health_label.text = "HEALTH: " + str(new_health)
	print("Vida atualizada para: ", new_health)
extends Control

@onready var player_name = $Panel/PlayerName
var score

func _on_restart_button_pressed():
	send_request('Anônimo')

func set_score(value):
	score = str(value)
	$Panel/Score.text = "SCORE: " + score
	
func set_hi_score(value):
	$Panel/HighScore.text = "HI-SCORE: " + str(value)
	
func send_request(data):
	var body = JSON.stringify({"name": data, "score": str(score)})
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request("https://spaceshooter.udianix.com.br/scores", headers, HTTPClient.METHOD_POST, body)

func _on_player_name_text_submitted(new_text):
	send_request(new_text)
	
func _on_http_request_request_completed(_result, response_code, _headers, _body):
	if response_code == 201:
		get_tree().change_scene_to_file("res://world.tscn")
	else:
		print("Failed to submit score. Response code: ", response_code)

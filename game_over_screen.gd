extends Control

@onready var player_name = $Panel/PlayerName
var score

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://world.tscn")

func set_score(value):
	score = str(value)
	$Panel/Score.text = "SCORE: " + score
	
func set_hi_score(value):
	$Panel/HighScore.text = "HI-SCORE: " + str(value)

func _on_player_name_text_submitted(new_text):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "name=" + new_text + "&score=" + score
	$HTTPRequest.request("http://localhost:8080/register.php", headers, HTTPClient.METHOD_POST, body)

func _on_http_request_request_completed(result, response_code, headers, body):
	get_tree().change_scene_to_file("res://world.tscn")

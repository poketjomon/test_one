extends CanvasLayer
class_name UI
@onready var timer_count_label = $PanelContainer/HBoxContainer/TimerPanel/TimerCountLabel
@onready var game_status_button = $PanelContainer/HBoxContainer/GameStatusButton
@onready var mines_count_label = $PanelContainer/HBoxContainer/MinesCountPanel/MinesCountLabel

var game_lost_button_texture = preload("res://Assets/button_dead.png")
var game_won_button_tsxture = preload("res://Assets/button_cleared.png")

func set_mine_count(mine_count:int):
	pass
	var mines_count_string = str(mine_count)
	if mines_count_string.length()<3:
		mines_count_string = mines_count_string.lpad(3,"0")
	mines_count_label.text = mines_count_string
func set_timer_count(time_count:int):
	var timer_string = str(time_count)
	#var mines_count_string = str(mine_count)
	if timer_string.length()<3:
		timer_string = timer_string.lpad(3,"0")
	timer_count_label.text = timer_string


func _on_game_status_button_pressed():
	pass # Replace with function body.
	get_tree().reload_current_scene()
func game_lost():
	game_status_button.texture_normal = game_lost_button_texture
func game_win():
	game_status_button.texture_normal = game_won_button_tsxture
	

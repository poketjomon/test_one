extends Node

@export var mines_grid:MineGrid
@onready var timer = $Timer
@export var ui:UI
var time_elapsed = 0

func _ready():
	mines_grid.game_lost.connect(on_game_lost)
	mines_grid.game_win.connect(on_game_win)
	mines_grid.flag_change.connect(on_flag_change)
	ui.set_mine_count(mines_grid.number_of_mines)
	 
func on_flag_change(flag_count:int):
	print(flag_count)
	ui.set_mine_count(mines_grid.number_of_mines-flag_count)
	pass
func _on_timer_timeout():
	time_elapsed +=1
	ui.set_timer_count(time_elapsed)
func on_game_lost():
	timer.stop()
	ui.game_lost()
func on_game_win():
	timer.stop()
	ui.game_win()

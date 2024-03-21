extends TileMap
class_name MineGrid

@export var columns = 8 # 列-x
@export var rows = 8 # 行-y
@export var number_of_mines = 10 # mine数量
# 定义tileset字典
const CELLS = {
				  "1": Vector2i(0, 0),
				  "2": Vector2i(1, 0),
				  "3": Vector2i(2, 0),
				  "4": Vector2i(3, 0),
				  "5": Vector2i(4, 0),
				  "6": Vector2i(0, 1),
				  "7": Vector2i(1, 1),
				  "8": Vector2i(2, 1),
				  "CLEAR": Vector2i(3, 1),
				  "MINE_RED": Vector2i(4, 1),
				  "FLAG": Vector2i(0, 2),
				  "MINE": Vector2i(1, 2),
				  "DEFAULT": Vector2i(2, 2)
			  }
const TILES_SET_ID            = 0
const DEFAULT_LAYER           = 0
var cells_with_mines          = [] # 坐标列表
var cells_checked_recursively = []
var cells_with_flags          = []
var flag_placed               = 0 # 放置的flag的数量
var is_game_finished          = false
signal flag_change(nunber_of_flag)
signal game_lost
signal game_win


func _ready():
	clear_layer(DEFAULT_LAYER)
	for i in range(rows):
		for j in range(columns):
			var cell_coord = Vector2i(i-rows/2, j-columns/2)
			set_tile_cell(cell_coord, "DEFAULT")
	place_mines()


# 输入事件
func _input(event: InputEvent):
	pass
	if is_game_finished:
		return
	if !(event is  InputEventMouseButton) || !event.is_pressed():
		return
	#print(event)
	#获取点击坐标
	var clicked_cell_coord = local_to_map(get_local_mouse_position())
	#print(event)
	if event is  InputEventMouseButton:
		if event.button_index == 1:
			on_cell_clicked(clicked_cell_coord)
		elif event.button_index == 2:
			print("PLACE FLAG")
			place_flag(clicked_cell_coord)


# 放置地雷
func place_mines():
	pass
	for i in range(number_of_mines):
		# 创建地雷单位坐标
		var cell_coordinates = Vector2(randi_range(-rows/2, rows/2-1), randi_range(-columns/2, columns/2-1))

		#如果地雷列表已存在单位坐标,则选一个新的坐标
		while cells_with_mines.has(cell_coordinates):
			cell_coordinates = Vector2(randi_range(-rows/2, rows/2-1), randi_range(-columns/2, columns/2-1))
		#坐标添加至地雷列表
		cells_with_mines.append(cell_coordinates)
	#据地雷列表的地雷坐标放置地雷
	for cell in cells_with_mines:
		#清除需要置地雷的位置的图案
		erase_cell(DEFAULT_LAYER, cell)
		#放置成含有地雷标识的默认图案-在tileset备选图案里
		set_cell(DEFAULT_LAYER, cell, TILES_SET_ID, CELLS.DEFAULT, 1)


# 放置图案
func set_tile_cell(cell_coord: Vector2, cell_type):
	set_cell(DEFAULT_LAYER, cell_coord, TILES_SET_ID, CELLS[cell_type])


# 鼠标点击单元格,1.存在地雷,2.无地雷->显示附近地雷数量
func on_cell_clicked(cell_coord: Vector2i):
	pass
	# 传过来的变量的坐标,在地雷标表中,则有地雷->游戏失败,显示全部地雷
	for cell in cells_with_mines:
		if cell.x==cell_coord.x && cell.y==cell_coord.y:
			print("YOU LOSE")
			lose(cell_coord)
			return
	# 如果没地雷,则应该显示附近地雷数量
	# 显示数量的格子,添加入已显示地雷数量列表
	cells_checked_recursively.append(cell_coord)
	handle_celles(cell_coord)
	
	# 消除flag
	if cells_with_flags.has(cell_coord):
		flag_placed -= 1
		flag_change.emit(flag_placed)
		cells_with_flags.erase(cell_coord)
	


# 单元格,计算附近地雷数量
func handle_celles(cell_coord: Vector2i):
	# 获取单元格数据
	var tile_data = get_cell_tile_data(DEFAULT_LAYER, cell_coord)
	#空表示是在点击方格外围
	if tile_data == null:
		return
	# 点击到方格,判断是否是地雷
	var cell_has_mine = tile_data.get_custom_data("has_mine")
	# 存在地雷
	if cell_has_mine:
		return
	#if not cell_has_mine:
	#不是地雷,计算附近地雷数量
	var mine_count = get_surrounding_cells_mine_count(cell_coord)
	
	# 周围地雷=0,且当前单元格不是地雷
	if mine_count == 0 and (not cells_with_mines.has(cell_coord)):
		set_tile_cell(cell_coord, "CLEAR")
		
		# 继续计算周围单元格
		var surrounding_cells = get_around_8_cells(cell_coord)
		for cell in surrounding_cells:
			if not cells_checked_recursively.has(cell):
				#cells_checked_recursively.append(cell)
				handle_surrounding_cell(cell)
	else:
		set_tile_cell(cell_coord, "%d" %mine_count)
		
	# 消除flag
	if cells_with_flags.has(cell_coord):
		flag_placed -= 1
		flag_change.emit(flag_placed)
		cells_with_flags.erase(cell_coord)
	


func handle_surrounding_cell(cell_coord: Vector2i):
	# 如果在已处理列表,则不处理
	if cells_checked_recursively.has(cell_coord):
		return
	cells_checked_recursively.append(cell_coord)
	handle_celles(cell_coord)

# 计算周围地雷数量
func get_surrounding_cells_mine_count(cell_coord: Vector2i):
	pass
	# 初始化数量为0
	var mine_count = 0
	#获取周围单元格坐标
	var surrounding_cells = get_around_8_cells(cell_coord)
	#逐个判断单元格否存在地雷
	for cell in surrounding_cells:
		# 获取单元格的数据
		var tile_data = get_cell_tile_data(DEFAULT_LAYER, cell)
		# 如果单元格存在,且有地雷,则计数
		if tile_data and tile_data.get_custom_data("has_mine"):
			mine_count +=1
	return mine_count


# 获取周围8格单元格
func get_around_8_cells(cell_coord: Vector2i) -> Array:
	var surrounding_cells = []

	# Define the offsets for adjacent cells
	var offsets = [
		Vector2i(-1, -1),  # Top-left
		Vector2i(0, -1),   # Top
		Vector2i(1, -1),   # Top-right
		Vector2i(-1, 0),   # Left
		Vector2i(1, 0),    # Right
		Vector2i(-1, 1),   # Bottom-left
		Vector2i(0, 1),    # Bottom
		Vector2i(1, 1)     # Bottom-right
	]

	# Iterate through offsets and add them to the current cell position
	for offset in offsets:
		var new_x = cell_coord.x + offset.x
		var new_y = cell_coord.y + offset.y

		# Add the new position to the list
		surrounding_cells.append(Vector2i(new_x, new_y))

	return surrounding_cells



# 处理周围单元格



func lose(cell_coord: Vector2i):
	game_lost.emit()
	is_game_finished = true
	for cell in cells_with_mines:
		set_tile_cell(cell, "MINE")
	set_tile_cell(cell_coord, "MINE_RED")


func place_flag(cell_coord: Vector2i):
	var tile_data = get_cell_tile_data(DEFAULT_LAYER, cell_coord)

	var atlast_coordinates = get_cell_atlas_coords(DEFAULT_LAYER, cell_coord)
	var is_empty_cell      = atlast_coordinates == Vector2i(2, 2)
	var is_flag_cell       = atlast_coordinates == Vector2i(0, 2)
	if !is_empty_cell && !is_flag_cell:
		return
		
	# 如果flag模块,再次点击即取消
	if is_flag_cell:
		set_tile_cell(cell_coord, "DEFAULT")
		cells_with_flags.erase(cell_coord)
		flag_placed -= 1
	# 放置flag
	elif is_empty_cell:
		if flag_placed == number_of_mines:
			print("标志数量等于地雷数量")
			return

		flag_placed += 1
		set_tile_cell(cell_coord, "FLAG")
		cells_with_flags.append(cell_coord)
	flag_change.emit(flag_placed)

	var count = 0
	for flag_cell in cells_with_flags:
		for mine_cell in cells_with_mines:
			if flag_cell.x == mine_cell.x and flag_cell.y == mine_cell.y:
				count +=1
	if count == cells_with_mines.size():
		print("WIN")
		win()


func win():
	is_game_finished = true
	game_win.emit()

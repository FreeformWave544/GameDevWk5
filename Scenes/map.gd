extends TileMapLayer

var patterns: Array[TileMapPattern] = []
@export var spawn_height := 10
@export var pattern_spacing := 5
@export var spawn_width := 10

var top_spawn_y := 0
var bottom_spawn_y := 0

@onready var player := get_parent().get_node_or_null("Player")

func _ready() -> void:
	if tile_set:
		patterns.append(tile_set.get_pattern(0))
		patterns.append(tile_set.get_pattern(1))
		patterns.append(tile_set.get_pattern(0))
		patterns.append(tile_set.get_pattern(1))
		patterns.append(tile_set.get_pattern(0))
		patterns.append(tile_set.get_pattern(1))
		patterns.append(tile_set.get_pattern(2))
	if player:
		var player_cell = local_to_map(player.global_position)
		top_spawn_y = player_cell.y - spawn_height
		bottom_spawn_y = player_cell.y + 1.0
		for y in range(top_spawn_y, bottom_spawn_y, pattern_spacing):
			spawn_pattern(y)

func _physics_process(_delta: float) -> void:
	if not player:
		print("Player not found!")
		return
	var player_cell = local_to_map(player.global_position)
	while bottom_spawn_y < player_cell.y + spawn_height:
		spawn_pattern(bottom_spawn_y)
		bottom_spawn_y += pattern_spacing
	while top_spawn_y > player_cell.y - spawn_height:
		top_spawn_y -= pattern_spacing
		spawn_pattern(top_spawn_y)

func spawn_pattern(y_cell: int) -> void:
	if patterns.is_empty():
		return
	var pattern = patterns[randi() % patterns.size()]
	var player_cell_x = local_to_map(player.global_position).x
	var x_cell = player_cell_x - spawn_width / 2.0 + randi() % spawn_width
	place_pattern(pattern, Vector2(x_cell, y_cell))

func place_pattern(pattern: TileMapPattern, cell_pos: Vector2i) -> void:
	for y in range(pattern.get_size().y):
		for x in range(pattern.get_size().x):
			var local_coords := Vector2i(x, y)
			if not pattern.has_cell(local_coords):
				continue
			var source_id := pattern.get_cell_source_id(local_coords)
			var atlas_coords := pattern.get_cell_atlas_coords(local_coords)
			var alt_tile := pattern.get_cell_alternative_tile(local_coords)
			set_cell(Vector2i(cell_pos.x + x, cell_pos.y + y), source_id, atlas_coords, alt_tile)

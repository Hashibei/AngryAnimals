extends TextureButton

const HOVER_SCALE: Vector2 = Vector2(1.1,1.1)
const DEFAULT_SCALE: Vector2 = Vector2(1.0,1.0)

@export var level_number: int = 1

@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel

var _level_scene: PackedScene

func _ready() -> void:
	level_label.text = str(level_number)
	var best_sc = ScoreManager.get_best_for_level(str(level_number))
	score_label.text = str(best_sc)
	_level_scene = load(get_level_path())

func get_level_path()-> String:
	return "res://scenes/levels/level_{level_number}/level_{level_number}.tscn".format({
		"level_number": level_number
	});

func _on_pressed() -> void:
	ScoreManager.set_level_selected(level_number)
	get_tree().change_scene_to_packed(_level_scene)


func _on_mouse_entered() -> void:
	scale = HOVER_SCALE

func _on_mouse_exited() -> void:
	scale = DEFAULT_SCALE

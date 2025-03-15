extends Control

const MAIN = preload("res://scenes/main/main.tscn")

@onready var ui_container: VBoxContainer = $MarginContainer/UIContainer
@onready var level_label: Label = $MarginContainer/UIContainer/LevelLabel
@onready var attempts_label: Label = $MarginContainer/UIContainer/AttemptsLabel

@onready var game_over_container: VBoxContainer = $MarginContainer/GameOverContainer

@onready var game_over_sound: AudioStreamPlayer2D = $GameOverSound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_label.text = "LEVEL %s" % ScoreManager.get_level_selected()
	update_attempts(0)
	SignalManager.score_update.connect(update_attempts)
	SignalManager.level_complete.connect(on_level_complete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu") == true:
		get_tree().change_scene_to_packed(MAIN)

func update_attempts(attempts: int):
	attempts_label.text = "Attempts %s" % attempts
	
func on_level_complete() -> void:
	game_over_container.show()
	game_over_sound.play()

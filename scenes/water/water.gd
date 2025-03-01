extends Area2D

@onready var water_sound_player: AudioStreamPlayer2D = $WaterSoundPlayer

func _ready() -> void:
	pass
	
func animal_entered(_body: Animal) -> void:
	water_sound_player.play()

extends Node2D

const ANIMAL = preload("res://scenes/animal/animal.tscn")

@onready var animal_spawn: Marker2D = $AnimalSpawn

func _ready() -> void:
	spawn_animal()
	SignalManager.animal_despawn.connect(respawn_animal)

func spawn_animal() -> void:
	var animal: Animal = ANIMAL.instantiate()
	animal.position = animal_spawn.position
	add_child(animal)

func respawn_animal() -> void:
	spawn_animal()

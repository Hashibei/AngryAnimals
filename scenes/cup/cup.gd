extends StaticBody2D

@onready var vanish_animation_player: AnimationPlayer = $VanishAnimationPlayer
@onready var cup_collision: CollisionPolygon2D = $CupCollision

func despawn()-> void:
	cup_collision.set_deferred("disabled",true)
	vanish_animation_player.play("vanish")

func _on_vanish_animation_finished(_anim_name: StringName) -> void:
	SignalManager.cup_destroyed.emit()
	queue_free()

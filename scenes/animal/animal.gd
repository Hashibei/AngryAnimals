extends RigidBody2D

class_name Animal

@onready var arrow_sound_player: AudioStreamPlayer2D = $ArrowSoundPlayer
@onready var launch_sound_player: AudioStreamPlayer2D = $LaunchSoundPlayer
@onready var kick_sound_player: AudioStreamPlayer2D = $KickSoundPlayer

@onready var arrow_sprite: Sprite2D = $ArrowSprite

#==========================================================#
#========================= STATE ==========================#
#==========================================================#

enum STATE {READY, DRAG, RELEASE}
var _state: STATE = STATE.READY

#==========================================================#
#======================== ANIMAL ==========================#
#==========================================================#

var _animal_starting_position: Vector2 = Vector2.ZERO

#==========================================================#
#========================= ARROW ==========================#
#==========================================================#

var ARROW_SCALE_IMPULSE_MAX: float = 1000.0

var _arrow_starting_scale_x: float = 0.0

#==========================================================#
#================== IMPULSE MULTIPLIER ====================#
#==========================================================#

var IMPULSE_MULTIPLIER: float = 20.0

#==========================================================#
#========================== DRAG ==========================#
#==========================================================#

const DRAG_LIMIT: Vector2 = Vector2(-60, 60)

var _drag_starting_position: Vector2 = Vector2.ZERO

#==========================================================#
#========================= READY ==========================#
#==========================================================#

func _ready() -> void:
	_arrow_starting_scale_x = arrow_sprite.scale.x
	arrow_sprite.hide()
	_animal_starting_position = position

#==========================================================#
#==================== PHYSICS PROCESS =====================#
#==========================================================#

func _physics_process(_delta: float) -> void:
	state_process()

func state_process() ->void:
	match _state:
		STATE.READY:
			pass
		STATE.DRAG:
			dragging()

#==========================================================#
#========================= STATE ==========================#
#==========================================================#

func set_state(value) -> void:
	_state = value
	match _state:
		STATE.DRAG:
			set_drag()
		STATE.RELEASE:
			set_release()

func set_drag()-> void:
	_drag_starting_position = get_global_mouse_position()
	arrow_sprite.show()

func set_release() ->void:
	arrow_sprite.hide()
	freeze = false
	apply_central_impulse(get_impulse())
	launch_sound_player.play()
	SignalManager.attempet_made.emit()

#==========================================================#
#========================= READY ==========================#
#==========================================================#

func on_click(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_ready(event):
		set_state(STATE.DRAG)
	
func is_ready(event)->bool:
	return _state == STATE.READY and event.is_action_pressed("click")

#==========================================================#
#========================= DRAG ===========================#
#==========================================================#

func dragging()-> void:
	if has_stopped_dragging():
		set_state(STATE.RELEASE)
		return
	
	drag()

func drag()->void:
	play_arrow_sound()
	drag_animal()
	animate_arrow()

func has_stopped_dragging()-> bool:
	return _state == STATE.DRAG and Input.is_action_just_released("click")

func was_dragged()-> bool:
	if(position != get_animal_position()):
		return true
	return false
	
func get_dragged_position()-> Vector2:
	var aux_dragged_distance = get_global_mouse_position() - _drag_starting_position
	return aux_dragged_distance.clampf(DRAG_LIMIT.x,DRAG_LIMIT.y)

#==========================================================#
#======================== IMPULSE =========================#
#==========================================================#

func get_impulse()-> Vector2:
	return get_dragged_position() * -1 * IMPULSE_MULTIPLIER

##==========================================================#
##====================== DRAG ANIMAL =======================#
##==========================================================#

func drag_animal()-> void:
	position = get_animal_position()

func get_animal_position()-> Vector2:
	return _animal_starting_position + get_dragged_position()

#==========================================================#
#==================== ARROW ANIMATE  ======================#
#==========================================================#

func animate_arrow()-> void:
	arrow_sprite.scale.x = get_arrow_scale()
	arrow_sprite.rotation = get_arrow_rotation()

func get_arrow_scale()-> float:
	var impulse_percentage = get_impulse().length() / ARROW_SCALE_IMPULSE_MAX
	return (_arrow_starting_scale_x * impulse_percentage) + _arrow_starting_scale_x

func get_arrow_rotation()-> float:
	return (_animal_starting_position - position).angle()

#==========================================================#
#=================== PLAY ARROW SOUND =====================#
#==========================================================#

func play_arrow_sound() -> void:
	if(was_dragged()):
		if(arrow_sound_player.playing == false):
			arrow_sound_player.play()

#==========================================================#
#==================== ANIMAL COLLIDED =====================#
#==========================================================#

func _on_animal_collided(_body: Node) -> void:
	if kick_sound_player.playing == false:
		kick_sound_player.play()

#==========================================================#
#================= SLEEPING STATE CHANGED =================#
#==========================================================#

func _on_animal_sleeping_state_changed() -> void:
	if sleeping == true:
		despawn_colling_cup()
		call_deferred("despawn")

#==========================================================#
#================= DESPAWN COLLIDING CUP ==================#
#==========================================================#

func despawn_colling_cup() -> void:
	var cup = get_colliding_bodies()[0]
	cup.despawn()

#==========================================================#
#===================== SCREEN EXITED ======================#
#==========================================================#

func _on_animal_screen_exited() -> void:
	despawn()

#==========================================================#
#======================== DESPAWN =========================#
#==========================================================#

func despawn()-> void:
	queue_free()
	SignalManager.animal_despawn.emit()

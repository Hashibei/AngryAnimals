extends RigidBody2D

class_name Animal

@onready var arrow_sound_player: AudioStreamPlayer2D = $ArrowSoundPlayer

#==========================================================#
#========================= STATE ==========================#
#==========================================================#

enum STATE {READY, DRAG, RELEASE}
var _state: STATE = STATE.READY: get = get_state, set = set_state

#==========================================================#
#======================= POSITION =========================#
#==========================================================#

var _starting_position: Vector2 = Vector2.ZERO

#==========================================================#
#========================== DRAG ==========================#
#==========================================================#

const DRAG_LIMIT: Vector2 = Vector2(-60, 60)

var _drag_starting_position: Vector2 = Vector2.ZERO:
	get:
		return _drag_starting_position
	set(gmp):
		_drag_starting_position = gmp

var _dragged_position: Vector2 = Vector2.ZERO:
	get:
		var aux_dragged_distance = get_global_mouse_position() - _drag_starting_position
		var aux_clamped_dragged_distance = aux_dragged_distance.clampf(DRAG_LIMIT.x,DRAG_LIMIT.y)
		return _starting_position + aux_clamped_dragged_distance

#==========================================================#
#========================= READY ==========================#
#==========================================================#

func _ready() -> void:
	_starting_position = position

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
		STATE.RELEASE:
			pass

#==========================================================#
#========================= STATE ==========================#
#==========================================================#

func get_state() -> STATE:
	return _state

func set_state(value) -> void:
	_state = value
	match _state:
		STATE.RELEASE:
			freeze = false
		STATE.DRAG:
			_drag_starting_position = get_global_mouse_position()

#==========================================================#
#========================= READY ==========================#
#==========================================================#

func on_click(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_ready(event):
		_state = STATE.DRAG
	
func is_ready(event)->bool:
	return _state == STATE.READY and event.is_action_pressed("click")

#==========================================================#
#========================= DRAG ===========================#
#==========================================================#

func dragging()-> void:
	if has_stopped_dragging():
		_state = STATE.RELEASE
		return
	
	drag()

func drag()->void:
	play_arrow_sound()
	position = _dragged_position

func has_stopped_dragging()-> bool:
	return _state == STATE.DRAG and Input.is_action_just_released("click")

func was_dragged()-> bool:
		if(position != _dragged_position):
			return true
		return false

#==========================================================#
#=================== Play Arrow Sound =====================#
#==========================================================#

func play_arrow_sound() -> void:
	if(was_dragged()):
		if(arrow_sound_player.playing == false):
			arrow_sound_player.play()

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

extends RigidBody2D

class_name Animal

#==========================================================#
#======================= POSITION =========================#
#==========================================================#

var starting_position: Vector2 = Vector2.ZERO

#==========================================================#
#========================= STATE ==========================#
#==========================================================#

enum STATE {READY, DRAG, RELEASE}
var state: STATE = STATE.READY

#==========================================================#
#========================== DRAG ==========================#
#==========================================================#

const DRAG_LIMIT: Vector2 = Vector2(-60, 60)
var drag_starting_position: Vector2 = Vector2.ZERO

#==========================================================#
#========================= READY ==========================#
#==========================================================#

func _ready() -> void:
	starting_position = position

#==========================================================#
#==================== PHYSICS PROCESS =====================#
#==========================================================#

func _physics_process(_delta: float) -> void:
	state_process()

func state_process() ->void:
	match state:
		STATE.READY:
			pass
		STATE.DRAG:
			dragging()
		STATE.RELEASE:
			pass

#==========================================================#
#========================= STATE ==========================#
#==========================================================#

func set_state(value) -> void:
	state = value
	match state:
		STATE.RELEASE:
			freeze = false
		STATE.DRAG:
			drag_starting_position = get_global_mouse_position()

#==========================================================#
#========================= READY ==========================#
#==========================================================#

func on_click(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if was_ready(event):
		set_state(STATE.DRAG)
	

func was_ready(event)->bool:
	return state == STATE.READY and event.is_action_pressed("click")

#==========================================================#
#========================= DRAG ===========================#
#==========================================================#

func dragging()-> void:
	if has_stopped_dragging():
		set_state(STATE.RELEASE)
		return
	
	drag()

func has_stoped_dragging()-> bool:
	return state == STATE.DRAG and Input.is_action_just_released("click")

func drag()->void:
	position = get_computed_position()

func get_dragged_distance()-> Vector2:
	return get_global_mouse_position() - drag_starting_position

func get_clamped_dragged_distance()-> Vector2:
	return get_dragged_distance().clampf(DRAG_LIMIT.x,DRAG_LIMIT.y)

func get_computed_position()-> Vector2:
	return starting_position + get_clamped_dragged_distance()

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

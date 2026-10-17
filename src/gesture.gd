extends Control
signal place_requested(screen: Vector2)
var placing: bool = false
signal shot(vector: Vector2, power: float)
signal drag_changed(power: float)
var enabled: bool = false
var dragging: bool = false
var origin: Vector2
var pointer: Vector2
var shooter_screen: Vector2
var cancel_text: String = ""
var power_text: String = ""
var instruction: String = ""
var touch_id: int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func cancel_center() -> Vector2:
	return Vector2(65,size.y-110)

func canceled() -> bool:
	return pointer.distance_to(cancel_center()) < 65

func drag_power() -> float:
	return clampf(origin.distance_to(pointer) / 200.0, 0.0, 1.0)

func _input(event: InputEvent) -> void:
	if not enabled:
		return
	if placing:
		if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
			place_requested.emit(event.position)
		elif event is InputEventScreenTouch and event.pressed:
			place_requested.emit(event.position)
		return
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1:
			begin(event.position,event.index)
		elif not event.pressed and event.index == touch_id:
			release(event.position)
	elif event is InputEventScreenDrag and event.index == touch_id:
		update_pointer(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			begin(event.position,-2)
		elif touch_id == -2:
			release(event.position)
	elif event is InputEventMouseMotion and touch_id == -2:
		update_pointer(event.position)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		abort()

func begin(pos: Vector2, id: int) -> void:
	if pos.distance_to(shooter_screen) > 110 or dragging:
		return
	origin = pos
	pointer = pos
	touch_id = id
	dragging = true
	queue_redraw()

func update_pointer(pos: Vector2) -> void:
	if dragging:
		pointer = pos
		drag_changed.emit(drag_power())
		queue_redraw()

func release(pos: Vector2) -> void:
	if not dragging:
		return
	pointer = pos
	var vector: Vector2 = origin-pointer
	var power: float = drag_power()
	var fire: bool = not canceled() and vector.length() > 16
	abort()
	if fire:
		shot.emit(vector.normalized(),power)

func abort() -> void:
	dragging = false
	touch_id = -1
	drag_changed.emit(0.0)
	queue_redraw()

func _draw() -> void:
	if not enabled:
		return
	var font: Font = get_theme_default_font()
	if not dragging:
		draw_arc(shooter_screen,42,0,TAU,48,Color(1,0.95,0.78,0.8),2,true)
		return
	var delta: Vector2 = pointer-origin
	var end: Vector2 = shooter_screen + delta.limit_length(200)
	draw_line(shooter_screen,end,Color(0.08,0.73,0.78,0.7),12,true)
	draw_circle(end,26,Color(0.1,0.85,0.88,0.4))
	draw_arc(end,29,0,TAU,32,Color.WHITE,2,true)
	var direction: Vector2 = -delta.normalized()
	for i in range(1,7):
		draw_circle(shooter_screen+direction*i*23,3.0,Color(1,0.97,0.87,0.9))
	draw_string(font,shooter_screen+Vector2(-75,-58),power_text+" "+str(roundi(drag_power()*100))+"%",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color.WHITE)
	draw_circle(cancel_center(),43,Color(0.65,0.18,0.15,0.9) if canceled() else Color(0.45,0.18,0.15,0.7))
	draw_line(cancel_center()+Vector2(-12,-12),cancel_center()+Vector2(12,12),Color.WHITE,4,true)
	draw_line(cancel_center()+Vector2(12,-12),cancel_center()+Vector2(-12,12),Color.WHITE,4,true)
	draw_string(font,cancel_center()+Vector2(52,8),cancel_text,HORIZONTAL_ALIGNMENT_LEFT,240,17,Color.WHITE)

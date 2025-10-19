class_name Camera
extends Camera3D

var minvec: Vector2 = Vector2(0.0, 0.0)
var maxvec: Vector2 = Vector2(0.0, 0.0)

@export var pan_speed: float = 0.5

const MIN_ZOOM: float = 100
const MAX_ZOOM: float = 1

func _process(delta: float) -> void:
	var dx = Input.get_action_strength("right") - Input.get_action_strength("left")
	var dy = Input.get_action_strength("up") - Input.get_action_strength("down")
	var alfa =  delta * pan_speed * self.size

	self.position.x = clamp(self.position.x + dx * alfa, minvec.x, maxvec.x)
	self.position.y = clamp(self.position.y + dy * alfa, minvec.y, maxvec.y)

func zoom_at_point(amount: float) -> void:
	self.size = clamp(self.size * amount, MAX_ZOOM, MIN_ZOOM)

var last_click_pos: Vector2
var last_click_world_pos: Vector3
var is_dragging: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_at_point(0.9)
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_at_point(1.1)
			if event.button_index == MOUSE_BUTTON_LEFT:
				last_click_pos = event.position
				last_click_world_pos = self.project_position(event.position, 10)
				is_dragging = true
		if event.is_released():
			is_dragging = false
	elif event is InputEventMouseMotion:
		if event.button_mask & 0b1 == 1:
			var diff = self.project_position(event.position, 10) - last_click_world_pos
			self.position -= diff

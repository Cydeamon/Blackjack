extends Area2D
var chip_value = 0;

signal mouse_clicked

func _on_Area2D_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		emit_signal("mouse_clicked", [self])

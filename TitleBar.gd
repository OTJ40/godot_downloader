extends Control


var following = false
var dragging_start_position = Vector2()

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			dragging_start_position = Vector2i(get_local_mouse_position())

func _process(_delta):
	if following:
		DisplayServer.window_set_position(DisplayServer.window_get_position() + Vector2i(get_global_mouse_position()) - dragging_start_position)
#		Window.set_position(Window.position + Vector2i(get_global_mouse_position()) - dragging_start_position)


func _on_close_button_pressed():
	get_tree().quit()


func _on_minimize_button_pressed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
#	OS.set_window_minimized(true)


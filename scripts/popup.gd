class_name ClosablePopup extends PopupPanel

@onready var _popup_text: Label = $VBoxContainer/PopupText
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	if not timer.time_left > 0:
		hide()


func _on_close_button_pressed():
	hide()


func show_popup(text: String, disable_auto_close: bool = false):
	set_text(text)
	show()
	move_to_center()
	if !disable_auto_close:
		timer.start(5)


func set_text(text: String):
	_popup_text.text = text


func _on_timer_timeout():
	hide()

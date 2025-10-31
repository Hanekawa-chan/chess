class_name ClosablePopup extends PopupPanel

@onready var _popup_text: Label = $VBoxContainer/PopupText
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	if not timer.time_left > 0:
		hide()


func _on_close_button_pressed():
	hide()


func show_popup(text: String):
	set_text(text)
	show()
	timer.start(5)


func set_text(text: String):
	_popup_text.text = text


func _on_timer_timeout():
	hide()

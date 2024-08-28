extends Control

@onready var name_edit: LineEdit = $MarginContainer/VBoxContainer/Settings/NameEdit
@onready var port_edit: SpinBox = $MarginContainer/VBoxContainer/Settings/PortEdit
@onready var advanced_button: Button = $MarginContainer/VBoxContainer/AdvancedButton

var advanced_mode : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name_edit.text = Net.get_server_name()
	reset_port()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_advanced_button_pressed() -> void:
	advanced_mode = !advanced_mode
	port_edit.visible = advanced_mode
	advanced_button.text = "Default" if advanced_mode else "Advanced"
	if not advanced_mode: reset_port()


func reset_port():
	port_edit.value = Net.DEFAULT_PORT


func _on_next_button_pressed() -> void:
	Net.set_server_name(name_edit.text)
	Net.server_port = port_edit.value
	SceneManager.fade_to_scene("host_screen")


func _on_back_button_pressed() -> void:
	SceneManager.fade_to_scene("host_or_join")

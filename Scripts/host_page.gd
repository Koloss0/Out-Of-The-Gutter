extends Control

@onready var connect: TextureButton = $Connect

# Called when the node enters the scene tree for the first time.
func _ready():
	connect.pressed.connect(on_connect_pressed)

func on_connect_pressed():
	Net.server_ip = $IP.text
	Net.server_port = $Port.text
	SceneManager.fade_to_scene("res://Scenes/host_page.tscn")

extends Control

@onready var connect: TextureButton = $Host

# Called when the node enters the scene tree for the first time.
func _ready():
	connect.pressed.connect(on_connect_pressed)

func on_connect_pressed():
	Net.server_ip = $IP.text
	Net.server_port = $Port.text
	Net.is_host = true
	SceneManager.fade_to_scene("res://Scenes/GamePage.tscn")

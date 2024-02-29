extends Node2D

@onready var join = $JoinButton
@onready var host = $HostButton
@onready var back = $BackButton

# Called when the node enters the scene tree for the first time.
func _ready():
	join.pressed.connect(on_join_pressed)
	host.pressed.connect(on_host_pressed)
	back.pressed.connect(on_back_pressed)

func on_join_pressed():
	SceneManager.fade_to_scene("res://Scripts/join_page.gd")

func on_host_pressed():
	SceneManager.fade_to_scene("res://Scripts/host_page.gd")

func on_back_pressed():
	SceneManager.fade_to_scene("res://Scripts/TitlePage.gd")

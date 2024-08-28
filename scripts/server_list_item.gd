class_name ServerListItem
extends Control

signal pressed

@onready var background: ColorRect = $Background
@onready var margin_container: MarginContainer = $MarginContainer
@onready var name_label: Label = $MarginContainer/HBoxContainer/Name
@onready var ip_label: Label = $MarginContainer/HBoxContainer/IPAddress

@export var standby_color : Color = 0x4b4b4bFF
@export var hovered_color : Color = 0x707070FF
@export var selected_color : Color = 0x848484FF

var server_name : String : set = set_server_name
var server_ip : String : set = set_server_ip
var selected : bool = false : set = set_selected
var hovered : bool = false

var server_data : Dictionary

func _ready() -> void:
	ip_label.text = server_ip
	name_label.text = server_name


func set_server_ip(ip : String):
	server_ip = ip
	if is_node_ready(): ip_label.text = server_ip


func set_server_name(value : String):
	server_name = value
	if is_node_ready(): name_label.text = server_name


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if hovered:
				selected = !selected
				pressed.emit()
				get_viewport().set_input_as_handled()


func _on_mouse_entered() -> void:
	hovered = true
	background.color = hovered_color


func _on_mouse_exited() -> void:
	hovered = false
	background.color = selected_color if selected else standby_color


func set_selected(state : bool):
	if state == selected: return
	selected = state
	if is_node_ready():
		background.color = selected_color if selected else standby_color


func _get_minimum_size() -> Vector2:
	return margin_container.get_minimum_size() if margin_container else Vector2.ZERO

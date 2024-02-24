extends Node2D

const PLATFORM = preload("res://Scenes/Pipe.tscn")
const MOVING_PLATFORM = preload("res://Scenes/Platforms/moving.tscn")

const MOVING_PLATFORM_CHANCE = 0.3

func generate_platforms():
	

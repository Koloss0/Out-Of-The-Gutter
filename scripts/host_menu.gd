
class_name HostMenu
extends Control

## Should return a resource containing the settings as set in the menu.
## The return type can be a gamemode-specific child class of Resource.
func get_settings() -> Resource:
	return null

## Should return the human-readable name of the game mode.
func get_pretty_name() -> String:
	return "Host Menu"

## Should return the shorthand path to the game mode, as defined in the SceneManager.
func get_game_screen_path() -> String:
	return "N/A"

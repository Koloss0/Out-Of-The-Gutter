# meta-name: Host Menu Preset
# meta-description: Predefined functions for host menus
# meta-default: false
# meta-space-indent: 4

extends HostMenu

## Should return a resource containing the settings as set in the menu.
## The return type can be a gamemode-specific child class of Resource.
func get_settings() -> Resource:
	return super.get_settings()

## Should return the human-readable name of the game mode.
func get_pretty_name() -> String:
	return super.get_pretty_name()

## Should return the shorthand path to the game mode, as defined in the SceneManager.
func get_game_screen_path() -> String:
	return super.get_game_screen_path()

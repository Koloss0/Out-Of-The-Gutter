extends CanvasLayer

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func alert(message: String) -> Signal:
	label.text = message
	animation_player.play("Alert")
	return animation_player.animation_finished

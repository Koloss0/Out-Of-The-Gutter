extends CanvasLayer

func alert(message: String):
	$Label.text = message
	$AnimationPlayer.play("Alert")

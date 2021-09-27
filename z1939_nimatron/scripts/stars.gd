extends Node2D


signal reset_game()
signal thinking_finished()


var thinking_time : float = 0
var is_thinking : bool = false


func _process(delta : float) -> void:
	if not $AnimationPlayer.current_animation == "Thinking":
		return
	if thinking_time < 0:
		$AnimationPlayer.get_animation("Thinking").loop = false
	thinking_time -= delta


func start_thinking(time : float) -> void:
	thinking_time = time
	is_thinking = true
	$AnimationPlayer.get_animation("Thinking").loop = true
	$AnimationPlayer.play("Thinking")


func initiate_reset() -> void:
	$AnimationPlayer.play("Reset")


func stop_reset() -> void:
	if $AnimationPlayer.current_animation == "Reset":
		$AnimationPlayer.stop(true)
	if is_thinking:
		$AnimationPlayer.play("Thinking")


func animation_finished(anim_name : String):
	if anim_name == "Thinking":
		is_thinking = false
		emit_signal("thinking_finished")
	
	elif anim_name == "Reset":
		emit_signal("reset_game")

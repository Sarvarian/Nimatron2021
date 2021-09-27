extends AnimatedSprite


func _ready() -> void:
	go_red()
#

func go_red() -> void:
	play("Red")
	$SubmitButton.disabled = true
#

func go_green() -> void:
	play("Green")
	$SubmitButton.disabled = false
#

func down() -> void:
	modulate.v = .5
#

func up() -> void:
	modulate.v = 1
#

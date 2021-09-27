class_name Builder
extends Node


static func player(main: Node) -> Object:
	var player = Player.new()
	player.main = main
	return player

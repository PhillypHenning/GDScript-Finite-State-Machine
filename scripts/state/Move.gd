# Idle.gd
extends State

func _ready() -> void:
	state_name = "Move"

# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	# We must declare all the properties we access through `owner` in the `Player.gd` script.
	#owner.velocity = Vector2.ZERO
	print("Move State Entered")


func update(delta: float) -> void:
	return
	print("Move State Update called")

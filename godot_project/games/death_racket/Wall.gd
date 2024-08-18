extends KinematicBody2D

export(float, 1.0, 1000.0) var speed = 30.0
export (float, 0.1, 100.0) var ball_acceleration = 1.3

var goal = null

export(NodePath) var racket_path
onready var racket = get_node(racket_path)

func _physics_process(_delta):
    if goal != null:
        # NB: not '* delta' (already used by move_and_slide())
        # warning-ignore:return_value_discarded
        move_and_slide((goal - position).normalized() * speed)


func hit_by_ball():
    if racket != null:
        goal = racket.initial_position
        racket.explode()
        racket = null

    return ball_acceleration

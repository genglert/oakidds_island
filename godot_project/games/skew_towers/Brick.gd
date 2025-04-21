extends RigidBody2D

signal frozen(brick)

var player_linear_velocity = Vector2.ZERO
var player_angular_velocity = 0.0

var _is_ragdoll = false
var _ragdoll_duration = 1.0  # Seconds

var collides_threshold = false

func _ready():
    # Avoid the brick to be stuck on a wall when the player press a direction
    get_physics_material_override().friction = 0.1


func _process(delta):
    if _is_ragdoll:
        _ragdoll_duration -= delta
        if _ragdoll_duration <= 0.0:
#            print('FREEZE')
            mode = MODE_KINEMATIC  # STATIC ??
            _is_ragdoll = false
            emit_signal("frozen", self)


func _integrate_forces(state):
    state.set_linear_velocity(
        Vector2.DOWN * weight * gravity_scale  # Gravity
        + player_linear_velocity               # Player's input
    )
    state.set_angular_velocity(player_angular_velocity)


func stop_player_control():
    # TODO: factorise
    player_linear_velocity = Vector2.ZERO
    player_angular_velocity = 0.0
    
    _is_ragdoll = true

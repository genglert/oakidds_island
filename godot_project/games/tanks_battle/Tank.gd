extends KinematicBody2D

signal killed(player_id)

const ANGLE_EPSILON: float = 0.01

export(int, 0, 3) var player_id = 0
export(bool) var cpu = false
export(String) var controller_id = "kb1"

export(float, 1.0, 1000.0) var speed = 150.0
export(float, 0.1, 360.0) var rotation_speed = 2.0
export(float) var attack_distance = 200.0

export(bool) var active = true

var shell_scn = preload("res://games/tanks_battle/Shell.tscn")
var shell = null

var explosion_scn = preload("res://games/BigExplosion.tscn")

# IA
onready var navigation_agent = $NavigationAgent
onready var parent = get_parent()
var target = null


func set_player(player):
    player_id = player.id
    cpu = player.cpu
    controller_id = player.controller_id


func _find_target():
    var others = []
    
    for tank_node in get_tree().get_nodes_in_group('TANKS'):
        if tank_node != self:
            others.append(tank_node)

    if not others:
        return null

    # Pick a random other tank
    # TODO: use a smarter way, using distance etc...
    return others[randi() % others.size()]


func _physics_process(delta):
    if not active:
        return
    
    if cpu:
        if not is_instance_valid(target):
            target = _find_target()

        if target != null:
            navigation_agent.set_target_location(target.global_position)

            if navigation_agent.is_navigation_finished():
                _shoot()
            else:
                var direction = navigation_agent.get_next_location() - global_position

                var angle_to_dest = Vector2.RIGHT.rotated(rotation).angle_to(direction)
                var angle_sign = sign(angle_to_dest)
                var angle_value = min(rotation_speed * delta, abs(angle_to_dest))

                if angle_value > ANGLE_EPSILON:
                    rotate(angle_sign * angle_value)
                else:
                    var move = Vector2.RIGHT.rotated(rotation) * speed
                    navigation_agent.set_velocity(move)  # Useful ??
                    # warning-ignore:return_value_discarded
                    move_and_slide(move)

                    if (target.global_position - global_position).length() <= attack_distance:
                        _shoot()
    else:
        # NB: not '* delta' (already used by move_and_slide())
        if Input.is_action_pressed("%s_up" % controller_id):
            # warning-ignore:return_value_discarded
            move_and_slide(Vector2.RIGHT.rotated(rotation) * speed)
        elif Input.is_action_pressed("%s_down" % controller_id):
            # warning-ignore:return_value_discarded
            move_and_slide(Vector2.LEFT.rotated(rotation) * speed)

        if Input.is_action_pressed("%s_right" % controller_id):
            rotate(rotation_speed * delta)
        elif Input.is_action_pressed("%s_left" % controller_id):
            rotate(-rotation_speed * delta)

        if Input.is_action_just_pressed("%s_action" % controller_id):
            _shoot()


func _shoot():
    if shell == null:
        shell = shell_scn.instance()
        shell.position = position + $ShellAnchor.position.rotated(rotation)
        shell.set_vector(Vector2.RIGHT.rotated(rotation))
        shell.connect("exploded", self, "_on_shell_exploded")

        get_parent().add_child(shell)


func _on_shell_exploded():
    shell = null


func shot_by_shell():
    # TODO: remove when finished?
    var explosion = explosion_scn.instance()
    explosion.position = position
    get_parent().add_child(explosion)
    explosion.emitting = true

    emit_signal("killed", player_id)
    queue_free()

    return true  # The shell must explode

extends KinematicBody2D

const EPSILON: float = 0.0001

export(float, 1.0, 10000.0) var speed = 300.0
export(float, 1.0, 10000.0) var max_speed = 3000.0

var vector = Vector2.ZERO
var active = true

var explosion_scn = preload("res://games/BigExplosion.tscn")
var sparks_scn = preload("res://games/ImpactSparks.tscn")


func _ready():
#    vector = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()

    # warning-ignore:return_value_discarded
    $ExplosionTimer.connect("timeout", self, "_on_Timer_explosion_timeout")


func _process(delta):
    var collision_info = move_and_collide(vector * speed * delta)

    if collision_info != null and collision_info.normal != Vector2.ZERO:
        var reflected_vector: Vector2 = vector.reflect(collision_info.normal)

        if active:
            var hit_by_ball_ref = funcref(collision_info.collider, "hit_by_ball")

            if hit_by_ball_ref.is_valid():
                accelerate(hit_by_ball_ref.call_func())
            else:
                printerr('Collider without "hit_by_ball()": ', collision_info.collider)

            var sparks = sparks_scn.instance()
            sparks.position = position
            sparks.rotation = collision_info.normal.angle()
            get_parent().add_child(sparks)

        # TODO: always add a small random factor? hummm
        if abs(vector.dot(reflected_vector) - 1) < EPSILON:
            # The ball rebounds orthogonally; we want to avoid this because we
            # could enter in an infinite rebound loop (opposite walls are parallel)
            reflected_vector = reflected_vector.rotated(rand_range(-0.1, 0.1))

        vector = - reflected_vector

#    return true


func start():
    vector = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()


# TODO: inline?
func accelerate(rate):
    speed = clamp(speed * rate, speed, max_speed)


# TODO: rename?
func deactivate():
    active = false
    $ExplosionTimer.start()


func _on_Timer_explosion_timeout():
    var explosion = explosion_scn.instance()
    explosion.position = position
    get_parent().add_child(explosion)
    explosion.emitting = true  # TODO: auto-start like sparks?

#    queue_free()
    visible = false  # To get a valid object for IA & avoid crash

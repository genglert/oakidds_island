extends KinematicBody2D

signal exploded

export(float, 1.0, 1000) var speed = 200.0
export(int, 1, 100) var max_collisions = 3

var vector = Vector2.RIGHT
var collision_count = 0


func set_vector(v):
    vector = v.normalized()


func explode():
    emit_signal("exploded")
    queue_free()


func shot_by_shell():
    explode()
    return true  # The other shell must explode too


func _physics_process(delta):
    var collision_info = move_and_collide(vector * speed * delta)

#    if collision_info != null and collision_info.normal != Vector2.ZERO:
    if collision_info != null:
        collision_count += 1

        var exploded = false
        var shot_by_shell_ref = funcref(collision_info.collider, "shot_by_shell")

        if shot_by_shell_ref.is_valid():  # Other shell, tank
            exploded = shot_by_shell_ref.call_func()

        if exploded or collision_count >= max_collisions:
            explode()
            return

        vector = - vector.reflect(collision_info.normal)

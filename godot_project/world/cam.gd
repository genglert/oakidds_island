extends Camera

export(float) var speed = 10.0
#export(Vector3) var offset = Vector3(0.0, 9.0,  7.5)
export(Vector3) var offset = Vector3(0.0, 6.0,  5.0)

var tracked = null


func track(obj_to_track):
    tracked = obj_to_track

func estimate_duration(obj_to_track):
    # TODO: factorise
    var length = ((obj_to_track.global_translation + offset) - global_translation).length()
    if length == 0.0:
        return 0.0
    
    return length / speed


func _process(delta):
    # NB: not a Tween because the tracked object can move
    if tracked != null:
        translate(
            ((tracked.global_translation + offset) - global_translation).limit_length(1.0) * delta * speed
        )

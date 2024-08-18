extends CPUParticles2D

func _ready():
    # warning-ignore:return_value_discarded
    $AutoDeleteTimer.connect("timeout", self, "_on_Timer_autodelete_timeout")
    # TODO: compute '$AutoDeleteTimer.wait_time' from 'lifetime'

    emitting = true
    $AutoDeleteTimer.start()


func _on_Timer_autodelete_timeout():
#    print('AUTODELETE')
    queue_free()

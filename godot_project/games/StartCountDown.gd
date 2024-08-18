extends ColorRect

signal finished

var count = 3

func _ready():
    # warning-ignore:return_value_discarded
    $Timer.connect("timeout", self, '_on_Time_time_out')


func _on_Time_time_out():
    if count == 1:
        emit_signal("finished")
        queue_free()
    else:
        get_node("Number%s" % count).visible = false

        count -= 1
        get_node("Number%s" % count).visible = true


func start():
    $Timer.start()

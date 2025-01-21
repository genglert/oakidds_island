extends ColorRect


func _ready():
    # warning-ignore:return_value_discarded
    $Timer.connect("timeout", self, '_on_Time_time_out')


#func _process(_delta):
#    if Input.is_action_just_released("ui_accept"):
#        start()


func _on_Time_time_out():
    visible = not visible


func start():
    $Timer.start()

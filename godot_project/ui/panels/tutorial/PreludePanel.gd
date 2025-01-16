extends Panel

signal completed

export(bool) var start_at_ready = true

var active = false
var completed_page = 0

# TODO: factorise (see ControllersPanel)
const controller_ids = [
    "kb1",
    "kb2",
    "jp1",
    "jp2",
    "jp3",
    "jp4",
]


func _ready():
    reset()

    # warning-ignore:return_value_discarded
    $AnimationPlayer.connect('animation_finished', self, '_on_animation_finished')

    if start_at_ready:
        go()


func _process(_delta):
#    if Input.is_action_just_released("ui_quit"):
#        get_tree().quit()

    if not active:
        return

    match completed_page:
        0:
            pass

        1:
            for controller_id in controller_ids:
                if Input.is_action_just_pressed("%s_action" % controller_id):
#                    print('GO TO PAGE 2')
                    $Page1.visible = false
                    $Page2.visible = true
                    $AnimationPlayer.play("explain_page2")

                    break

        2:
            for controller_id in controller_ids:
                if Input.is_action_just_pressed("%s_action" % controller_id):
#                    print('COMPLETED')
                    emit_signal("completed")
                    active = false

                    break


func go():
    assert(not active)
    assert(completed_page == 0)

    active = true
    $Page1.visible = true
    $AnimationPlayer.play("explain_page1")


func reset():
#    assert(completed_page == 2)

    completed_page = 0

    $Page1.visible = false
    $Page2.visible = false
    $AnimationPlayer.play("RESET")


func _on_animation_finished(anim_name):
    match anim_name:
        "explain_page1":
            completed_page = 1

        "explain_page2":
            completed_page = 2

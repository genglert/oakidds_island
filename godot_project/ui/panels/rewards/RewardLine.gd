extends Control

func set_reward(reward):
    $Label.text = '+ %s' % reward.cards.size()
    $Portrait.texture = load('res://avatar/images/%s-portrait.png' % reward.player.avatar_id)

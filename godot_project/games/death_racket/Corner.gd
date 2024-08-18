extends StaticBody2D

export (float, 0.1, 100.0) var ball_acceleration = 1.1

func hit_by_ball():
    return ball_acceleration

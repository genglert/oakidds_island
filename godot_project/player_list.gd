extends Object

class_name PlayerList

var _players = []
var _Player = load("player.gd")


func _init():
    populate()


func populate():
    # NB: tryied a colorblind-friendly palette (sibset of the IBM's one)
    #     - chose the palette in the option menu?
    #     - add some icon/pattern too? (would be hard when player's sprite is small)

    var player1 = create_player()
    player1.cpu = false
    player1.controller_id = "kb1"
    player1.avatar_id = "woodlouse"
    player1.color = Color("#648FFF")

    var player2 = create_player()
    player2.smartness = player2.Smartness.HIGH
    player2.avatar_id = "moth"
    player2.color = Color("#785EF0")
#    player2.cpu = false
#    player2.controller_id = "kb2"
    player2.name += " (CPU)"

    var player3 = create_player()
    player3.avatar_id = "shrew"
    player3.color = Color("#FE6100")
    player3.name += " (CPU)"
#    player3.cpu = false
#    player3.controller_id = "jp1"

    var player4 = create_player()
    player4.smartness = player4.Smartness.LOW
    player4.avatar_id = "slug"
    player4.color = Color("#FFB000")
    player4.name += " (CPU)"


func reset():
    _players.clear()
    populate()


func create_player(name=null):
    var player = _Player.new(_players.size())
    _players.append(player)

    if name == null:
        name = "Player %s" % (player.id + 1)

    player.name = name

    return player


func get_player(player_id):
    return _players[player_id]


# TODO: get_other_players()? VS get_player=>get()/player()
func other_players(player_id) -> Array:
    var other_players = []

    for player in _players:
        if player.id != player_id:
            other_players.append(player)

    return other_players


func size():
    return self._players.size()

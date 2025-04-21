extends Object

class_name Scores

var _players: PlayerList
var _scores = {}  # player_id => int


func _init(players: PlayerList):
    _players = players

    for player_id in players.size():
        _scores[player_id] = 0


func increment_score(player_id, value: int):
    # TODO: assert id is ok?
    _scores[player_id] += value


# We build a ranking (Array of array of Players -- index 0 are winners etc...)
func final_ranking() -> Array:
    var ranking = []

    # We remove duplicated scores
    var values_set = {}
    for value in _scores.values():
        values_set[value] = null

    # Ascending sort of scores
    var score_values = values_set.keys()
    score_values.sort()
    score_values.invert()

    for value in score_values:
        var tier_players = []

        for player_id in _scores:
            if _scores[player_id] == value:
                tier_players.append(_players.get_player(player_id))

        ranking.append(tier_players)

        # NB: if there are 2 players at first place, there is no player at second place etc...
        for _extra in range(1, tier_players.size()):
            ranking.append([])

    return ranking

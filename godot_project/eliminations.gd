extends Object

class_name Eliminations

var _players: PlayerList

# Array of arrays of player IDs
# Index 0 for players elimited first
# Index 2 for players elimited seconc...
# That's why we invert the data when building the final ranking
#var _data: Array = []
var _eliminated_ids: Array = []

var _not_eliminated: int

# NB1: see fill()
# NB2: yes we could just set 6 = 0 + 1 + 2 + 3 ...
var ids_sum = 0


func _init(players: PlayerList):
    _players = players
    _not_eliminated = players.size()

    for player_id in _not_eliminated:
        ids_sum += player_id
        _eliminated_ids.append([])


func eliminate(player_ids: Array):
    for i in _eliminated_ids.size():
        var ranked = _eliminated_ids[i]

        if not ranked:
            ranked.append_array(player_ids)
            break

    _not_eliminated -= player_ids.size()

    return self


func not_eliminated_count() -> int:
    return _not_eliminated


func fill():
    assert(_not_eliminated == 1)
    assert(_eliminated_ids[-1].size() == 0)

    var last_id = ids_sum

    for ranked in _eliminated_ids:
        for player_id in ranked:
            last_id -= player_id

    _eliminated_ids[-1].append(last_id)
    _not_eliminated = 0

    return self


# We build a ranking (Array of array of Players -- index 0 are winners etc...)
# We take care to holes (the first place must be filled, if there are 2 players,
# at first place, there is no player at second place etc...)
func final_ranking() -> Array:
    assert(_not_eliminated == 0)

    var ranking = []

    for i in range(_eliminated_ids.size(), 0, -1):
        var player_ids = _eliminated_ids[i - 1]

        if player_ids:
            var rank_players = []
            for player_id in player_ids:
                rank_players.append(_players.get_player(player_id))
            ranking.append(rank_players)

            for _extra in range(1, player_ids.size()):
                ranking.append([])

    return ranking

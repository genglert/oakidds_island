extends MeshInstance

# BlockType
enum {NONE, UNDER, GRASS, ROAD}

const rayon = 1.0
const ROW_HEIGHT_RATIO = 0.8660254037844386  # NB: sin(PI / 3)
const MAP = [
    [[NONE,  0.0], [NONE,  0.0], [NONE,  0.0], [NONE,  0.0], [UNDER, 0.5], [UNDER, 0.5], [UNDER, 0.5], [GRASS, 1.1], [GRASS, 1.1], [GRASS, 1.1], [UNDER, 0.5], [UNDER, 0.5], [NONE, 0.5], [NONE,  0.0], [NONE,  0.0]],
    [[NONE,  0.0], [UNDER, 0.5], [UNDER, 0.5], [UNDER, 0.5], [UNDER, 0.5], [GRASS, 1.1], [GRASS, 1.1], [GRASS, 1.2], [GRASS, 1.2], [GRASS, 1.2], [GRASS, 1.1], [UNDER, 0.5], [UNDER, 0.5], [UNDER, 0.5], [NONE, 0.5]],
    [[UNDER, 0.2], [UNDER, 0.5], [GRASS, 1.1], [ROAD,  1.1], [ROAD,  1.1], [ROAD,  1.2], [ROAD,  1.2], [ROAD,  1.5], [ROAD, 1.5],  [ROAD,  1.5], [GRASS, 1.2], [GRASS, 1.1], [UNDER, 0.5], [UNDER, 0.5], [UNDER, 0.5]],
    [[UNDER, 0.5], [GRASS, 1.1], [ROAD,  1.2], [GRASS, 1.2], [GRASS, 1.1], [GRASS, 1.2], [GRASS, 1.5], [GRASS, 1.7], [GRASS, 1.6], [GRASS, 1.5], [ROAD,  1.5], [GRASS, 1.2], [GRASS, 1.1], [UNDER, 0.5], [UNDER, 0.5]],
    [[UNDER, 0.3], [UNDER, 0.6], [ROAD,  1.1], [ROAD,  1.2], [GRASS, 1.2], [GRASS, 1.5], [GRASS, 1.7], [GRASS, 1.8], [GRASS, 1.8], [GRASS, 1.7], [ROAD,  1.5], [ROAD,  1.5], [GRASS, 1.2], [GRASS, 1.1], [UNDER, 0.5]],
    [[NONE,  0.0], [UNDER, 0.6], [GRASS, 1.1], [ROAD,  1.2], [GRASS, 1.5], [GRASS, 1.6], [GRASS, 1.7], [GRASS, 1.8], [GRASS, 1.8], [GRASS, 1.8], [GRASS, 1.6], [ROAD,  1.5], [GRASS, 1.2], [GRASS, 1.1], [UNDER, 0.5]],
    [[UNDER, 0.6], [GRASS, 1.1], [ROAD,  1.2], [GRASS, 1.5], [GRASS, 1.5], [GRASS, 1.5], [GRASS, 1.5], [GRASS, 1.7], [GRASS, 1.8], [GRASS, 1.7], [ROAD,  1.5], [GRASS, 1.2], [GRASS, 1.1], [UNDER, 0.5], [UNDER, 0.5]],
    [[UNDER, 0.5], [GRASS, 1.1], [ROAD,  1.2], [GRASS, 1.5], [GRASS, 1.5], [GRASS, 1.5], [GRASS, 1.2], [GRASS, 1.2], [GRASS, 1.2], [GRASS, 1.5], [ROAD,  1.5], [ROAD,  1.5], [GRASS, 1.2], [GRASS, 1.1], [UNDER, 0.5]],
    [[UNDER, 0.5], [UNDER, 0.5], [ROAD,  1.1], [ROAD,  1.2], [GRASS, 1.5], [ROAD,  1.2], [ROAD,  1.1], [ROAD,  1.1], [UNDER, 0.5], [GRASS, 1.2], [GRASS, 1.5], [ROAD,  1.2], [GRASS, 1.2], [GRASS, 1.1], [UNDER, 0.5]],
    [[UNDER, 0.2], [UNDER, 0.5], [UNDER, 0.6], [GRASS, 1.1], [ROAD,  1.2], [GRASS, 1.2], [UNDER, 0.6], [GRASS, 1.1], [ROAD,  1.1], [ROAD,  1.2], [ROAD,  1.5], [GRASS, 1.2], [GRASS, 1.1], [UNDER, 0.5], [UNDER, 0.5]],
    [[NONE,  0.0], [NONE,  0.0], [UNDER, 0.5], [UNDER, 0.5], [GRASS, 1.1], [GRASS, 1.2], [UNDER, 0.4], [UNDER, 0.7], [UNDER, 0.5], [GRASS, 1.2], [GRASS, 1.2], [GRASS, 1.2], [GRASS, 1.1], [UNDER, 0.5], [NONE,  0.0]],
    [[NONE,  0.0], [NONE,  0.0], [NONE,  0.0], [NONE,  0.0], [UNDER, 0.7], [UNDER, 0.6], [UNDER, 0.3], [NONE,  0.0], [UNDER, 0.5], [UNDER, 0.6], [UNDER, 0.6], [UNDER, 0.6], [UNDER, 0.5], [NONE,  0.0], [NONE,  0.0]],
]

class Case:
    var top: Vector3 = Vector3.ZERO
    var type = NONE  # BlockType
    var row_idx: int = 0  # TODO: really useful?
    var col_idx: int = 0  # TODO: really useful?
    var road_idx: int = 0
    var free = true  # Is a building on it (see allocate_random_grass_block())

    func to_string():
        return "Case(top={0}, type={1}, row={2}, col={3}), road={4}".format([
            top, type, row_idx, col_idx, road_idx
        ])


var cases: Array = []
var road_end_idx: int = 0


func _ready():
    randomize()
    make_blocks()
    make_road()


func add_triangle_indices(surface, index_offset, index_1, index_2, index_3):
    surface.add_index(index_offset + index_1)
    surface.add_index(index_offset + index_2)
    surface.add_index(index_offset + index_3)


func add_quad_indices(surface, index_offset, index_1, index_2, index_3, index_4):
    add_triangle_indices(surface, index_offset, index_1, index_2, index_3)
    add_triangle_indices(surface, index_offset, index_1, index_3, index_4)


func make_block(surface, origin, index_offset, block_type, height=2.0, rayon=1.0):
    # Vertices ---
    var half_rayon = rayon / 2.0
    var almost_rayon = rayon * ROW_HEIGHT_RATIO

    var block_type_vector = null

    match(block_type):
        GRASS, UNDER:
            block_type_vector = Vector2(0, 0)
        ROAD:
            block_type_vector = Vector2(0.5, 0)
#            print('origin: ', origin)
        _:  # NONE
            return 0

    # Top
    surface.add_uv(block_type_vector + Vector2(0, 0.25))
    surface.add_vertex(origin + Vector3(-rayon,      height,             0)) # 0 (offset)
    surface.add_uv(block_type_vector + Vector2(0.125, 0.5))
    surface.add_vertex(origin + Vector3(-half_rayon, height, -almost_rayon)) # 1
    surface.add_uv(block_type_vector + Vector2(0.375, 0.5))
    surface.add_vertex(origin + Vector3( half_rayon, height, -almost_rayon)) # 2
    surface.add_uv(block_type_vector + Vector2(0.5, 0.25))
    surface.add_vertex(origin + Vector3( rayon,      height,             0)) # 3
    surface.add_uv(block_type_vector + Vector2(0.375, 0))
    surface.add_vertex(origin + Vector3( half_rayon, height,  almost_rayon)) # 4
    surface.add_uv(block_type_vector + Vector2(0.125, 0))
    surface.add_vertex(origin + Vector3(-half_rayon, height,  almost_rayon)) # 5

    # Side (top)
    surface.add_uv(Vector2(0, 0.5))
    surface.add_vertex(origin + Vector3(-rayon,      height,             0)) # 6
    surface.add_uv(Vector2(1.0 / 3.0, 0.5))
    surface.add_vertex(origin + Vector3(-half_rayon, height, -almost_rayon)) # 7
    surface.add_uv(Vector2(2.0 / 3.0, 0.5))
    surface.add_vertex(origin + Vector3( half_rayon, height, -almost_rayon)) # 8
    surface.add_uv(Vector2(1.0, 0.5))
    surface.add_vertex(origin + Vector3( rayon,      height,             0)) # 9
    surface.add_uv(Vector2(3.0 / 3.0, 0.5))
    surface.add_vertex(origin + Vector3( half_rayon, height,  almost_rayon)) # 10
    surface.add_uv(Vector2(1.0 / 3.0, 0.5))
    surface.add_vertex(origin + Vector3(-half_rayon, height,  almost_rayon)) # 11

    # Side (bottom)
    surface.add_uv(Vector2(0, 1.0))
    surface.add_vertex(origin + Vector3(-rayon,      0,             0)) # 12
    surface.add_uv(Vector2(1.0 / 3.0, 1.0))
    surface.add_vertex(origin + Vector3(-half_rayon, 0, -almost_rayon)) # 13
    surface.add_uv(Vector2(2.0 / 3.0, 1.0))
    surface.add_vertex(origin + Vector3( half_rayon, 0, -almost_rayon)) # 14
    surface.add_uv(Vector2(1.0, 1.0))
    surface.add_vertex(origin + Vector3( rayon,      0,             0)) # 15
    surface.add_uv(Vector2(2.0 / 3.0, 1.0))
    surface.add_vertex(origin + Vector3( half_rayon, 0,  almost_rayon)) # 16
    surface.add_uv(Vector2(1.0 / 3.0, 1.0))
    surface.add_vertex(origin + Vector3(-half_rayon, 0,  almost_rayon)) # 17

    # Indices ---
    # Top
    add_triangle_indices(surface, index_offset, 0, 1, 5)
    add_quad_indices(surface, index_offset, 1, 2, 4, 5)
    add_triangle_indices(surface, index_offset, 2, 3, 4)

    # Side
    add_quad_indices(surface, index_offset,  6, 12, 13,  7)
    add_quad_indices(surface, index_offset,  7, 13, 14,  8)
    add_quad_indices(surface, index_offset,  8, 14, 15,  9)
    add_quad_indices(surface, index_offset,  9, 15, 16, 10)
    add_quad_indices(surface, index_offset, 10, 16, 17, 11)
    add_quad_indices(surface, index_offset, 11, 17, 12,  6)

    return 18


func make_blocks():
    var surface = SurfaceTool.new()
    var index_offset = 0

    surface.begin(Mesh.PRIMITIVE_TRIANGLES)

    for row_idx in MAP.size():
        var row = MAP[row_idx]
        var cases_row = []
        
        for col_idx in row.size():
            var block_info = row[col_idx]
            var block_type = block_info[0]
            var block_height = block_info[1]

            var origin = Vector3(
                col_idx * rayon * 1.5,
                -1,  # All blocks start under water
                (row_idx * 2 + col_idx % 2) * rayon * ROW_HEIGHT_RATIO
            )
            var final_height = block_height + rand_range(0, 0.3)

            var case = Case.new()
            case.top = origin + Vector3(0, final_height, 0)
            case.type = block_type
            case.row_idx = row_idx
            case.col_idx = col_idx

            cases_row.append(case)

            # NB: we need NONE cases to have a consistent grid, but 3D model avoids them
            if block_type != NONE:
            # TODO: else other texture....
                index_offset += make_block(
                    surface,
                    origin,
                    index_offset,
                    block_type,
                    final_height,
                    rayon
                )

        cases.append(cases_row)

    surface.generate_normals()
    self.mesh = surface.commit()

func debug_get_position(row_idx, col_idx):
    var case = cases[row_idx][col_idx]
    print('CASE: ', case.to_string(), " ", row_idx, ' ', col_idx)

    return case.top

func get_road_position(index):
    if index > road_end_idx:
        return null
    
    for cases_row in cases:
        for case in cases_row:
            if case.road_idx == index:
                return case.top

func _first_road_case():
    for row_idx in range(MAP.size() - 1, -1, -1):
        for case in cases[row_idx]:
            if case.type == ROAD:
                return case

    printerr('No road case found.')
    get_tree().quit(1)

func _neighbours_cases(case: Case):
    var row_idx = case.row_idx
    var col_idx = case.col_idx

    if col_idx % 2 == 1:
        return [
            cases[row_idx - 1][col_idx],
            cases[row_idx    ][col_idx + 1],
            cases[row_idx + 1][col_idx + 1],
            cases[row_idx + 1][col_idx],
            cases[row_idx + 1][col_idx - 1],
            cases[row_idx    ][col_idx - 1],
        ]

    # col_idx % 2 == 0:
    return [
        cases[row_idx - 1][col_idx],
        cases[row_idx - 1][col_idx + 1],
        cases[row_idx    ][col_idx + 1],
        cases[row_idx + 1][col_idx],
        cases[row_idx    ][col_idx - 1],
        cases[row_idx - 1][col_idx - 1],
    ]

func _find_next_road_case(case):
#    print(case.to_string())
    for neighbour in _neighbours_cases(case):
#        print(' N=', neighbour.to_string(), ' ', ROAD, ' ', neighbour.type == ROAD, ' ', neighbour.road_idx == 0)
        if neighbour.type == ROAD and neighbour.road_idx == 0:
            return neighbour

    return null

func make_road():
    var road_idx = 1
    var current_case = _first_road_case()
    current_case.road_idx = road_idx
    road_idx += 1

    for i in (cases.size() * cases[0].size()):  # we avoid a <while true>
        var case = _find_next_road_case(current_case)
        if case == null:
            # TODO: check that the end is close to the start?
            road_end_idx = current_case.road_idx
#            print_debug('END IDX: ', road_end_idx)
            return
        else:
            case.road_idx = road_idx
            road_idx += 1
            current_case = case

    printerr('The road is not closed.')
    get_tree().quit(1)


#func get_random_grass_postion():
func allocate_random_grass_block():
    var grass_count = 0  # TODO: "cache" ?
    for row_idx in range(MAP.size()):
        for case in cases[row_idx]:
            if case.type == GRASS and case.free:
                grass_count += 1

    if grass_count == 0:
        printerr('Allocate_random_grass_block(): no block available anymore.')
        get_tree().quit(1)

    var idx = randi() % grass_count

    for row_idx in range(MAP.size()):
        for case in cases[row_idx]:
            if case.type == GRASS and case.free:
                if idx == 0:
#                    return case.top
                    case.free = false
                    return case
                
                idx -= 1

#    printerr('Bug in get_random_grass_block(); no grass case picked')
    printerr('Bug in allocate_random_grass_block(); no block picked?!')
    get_tree().quit(1)

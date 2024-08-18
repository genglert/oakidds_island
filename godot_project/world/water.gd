extends MeshInstance


func _ready():
    var surface = SurfaceTool.new()
    var size = 50
    var height = 0
    var tex_ratio = Vector2(20, 20)

    surface.begin(Mesh.PRIMITIVE_TRIANGLES)

    surface.add_uv(tex_ratio * Vector2(0, 0))
    surface.add_vertex(Vector3(-size, height, -size)) # 0 (offset)
    surface.add_uv(tex_ratio * Vector2(1, 0))
    surface.add_vertex(Vector3( size, height, -size)) # 1
    surface.add_uv(tex_ratio * Vector2(1, 1))
    surface.add_vertex(Vector3( size, height,  size)) # 2
    surface.add_uv(tex_ratio * Vector2(0, 1))
    surface.add_vertex(Vector3(-size, height,  size)) # 3

    # TODO: use add_triangle_indices() ?
    surface.add_index(0)
    surface.add_index(1)
    surface.add_index(2)
    surface.add_index(0)
    surface.add_index(2)
    surface.add_index(3)

    surface.generate_normals()
    self.mesh = surface.commit()

extends MeshInstance

var sprite_name = 'pig'
#var size = 3
var size = 1.5

func _ready():
    var material = SpatialMaterial.new()
    material.albedo_color = Color(1.0, 1.0, 1.0)
    material.albedo_texture = load('res://avatar/images/%s.png' % sprite_name)
    material.flags_transparent = true

    var surface = SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)

    # NB: top vertices are slightly shifted to the back (to get a kind of billboard)
    surface.add_uv(Vector2(0, 0))
    surface.add_vertex(Vector3(-size/2.0, size, -size/4.0)) # 0
    surface.add_uv(Vector2(1, 0))
    surface.add_vertex(Vector3( size/2.0, size, -size/4.0)) # 1
    surface.add_uv(Vector2(1, 1))
    surface.add_vertex(Vector3( size/2.0, 0,  0)) # 2
    surface.add_uv(Vector2(0, 1))
    surface.add_vertex(Vector3(-size/2.0, 0,  0)) # 3

    # TODO: use add_triangle_indices() ?
    surface.add_index(0)
    surface.add_index(1)
    surface.add_index(2)
    surface.add_index(0)
    surface.add_index(2)
    surface.add_index(3)

    surface.generate_normals()
    self.mesh = surface.commit()
    self.set_surface_material(0, material)

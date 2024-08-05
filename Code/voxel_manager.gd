extends Node3D
const SIZE = 48
var voxel_grid: Array = []
var color_grid: Array = []
var voxels_present = 0
var meshinstance = null
func init_voxel_grid(width, height, depth):
	for z in range(depth):
		var layer: Array = []
		for y in range(height):
			var row: Array = []
			for x in range(width):
				var tilepresent = [false, [Color(1,1,1), Color(1,1,1), Color(1,1,1)]]
				row.append(tilepresent)  # false means the voxel is empty
				voxels_present += 1 if tilepresent else 0
			layer.append(row)
		voxel_grid.append(layer)
	return voxel_grid
	
func combine_voxel_meshes(_voxel_grid):
	var mesher = SurfaceTool.new()
	mesher.begin(Mesh.PRIMITIVE_TRIANGLES)
	mesher.set_smooth_group(-1)
	# Define the 8 vertices of a unit cube
	var vertices = [
		Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(0, 1, 0),
		Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(0, 1, 1)
	]
	
	# Define the 12 triangles (indices) that make up the 6 faces of the cube
	var faces = [
		[0, 1, 2], [0, 2, 3],  # Front face
		[5, 4, 7], [5, 7, 6],  # Back face
		[3, 2, 6], [3, 6, 7],  # Top face
		[1, 0, 4], [1, 4, 5],  # Bottom face
		[4, 0, 3], [4, 3, 7],  # Left face
		[1, 5, 6], [1, 6, 2]   # Right face
	]
	
	for z in range(_voxel_grid.size()):
		for y in range(_voxel_grid[z].size()):
			for x in range(_voxel_grid[z][y].size()):
				if _voxel_grid[z][y][x][0]:
					for face in faces:
						mesher.set_color(_voxel_grid[z][y][x][1][0])
						mesher.add_vertex(vertices[face[0]] + Vector3(x, y, z))
						mesher.add_vertex(vertices[face[1]] + Vector3(x, y, z))
						#mesher.set_color(_voxel_grid[z][y][x][1][2])
						mesher.add_vertex(vertices[face[2]] + Vector3(x, y, z))
	mesher.generate_normals()
	var combined_mesh = mesher.commit()
	return combined_mesh
	
func update_voxels_from_sprite(img1,img2,img3):

	for x in range(SIZE):
		for y in range(SIZE):
			for z in range(1, SIZE):
				var pixel1 = img1.get_pixel(x, y)
				var pixel2 = img2.get_pixel(SIZE - z, y)
				var pixel3 = img3.get_pixel(x, SIZE - z)

				if pixel1.a > 0.5 and pixel2.a > 0.5 and pixel3.a > 0.5:
					voxel_grid[x][SIZE - 1 - y][z] = [true, [pixel1, pixel2, pixel3]]
				else:
					voxel_grid[x][SIZE - 1 - y][z] = [false, [Color(1,1,1), Color(1,1,1), Color(1,1,1)]]
	
func render_voxel_grid(_voxel_grid):
	var combined_mesh = combine_voxel_meshes(_voxel_grid)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = combined_mesh
	mesh_instance.cast_shadow = true
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mesh_instance.material_override = mat
	meshinstance = mesh_instance
	add_child(mesh_instance)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	voxel_grid = init_voxel_grid(SIZE, SIZE, SIZE)
	# load sprites
	var sprite1 = Image.load_from_file("res://Sprites/sfront.png")  # front view
	var sprite2 = Image.load_from_file("res://Sprites/sside.png")  # side view
	var sprite3 = Image.load_from_file("res://Sprites/top.png")  # top view

	update_voxels_from_sprite(sprite1, sprite2, sprite3)
	render_voxel_grid(voxel_grid)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

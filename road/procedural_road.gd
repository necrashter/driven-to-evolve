@tool
class_name ProceduralRoad
extends Node3D

const NEON_MAT := preload("res://road/neon.material")
const ROAD_MAT := preload("res://road/road.material")

@export var road_width: float = 20.0
@export var barrier_width: float = 1.0
@export var barrier_shoulder: float = 0.5
@export var barrier_height: float = 1.5
@export var segment_count: int = 6
@export var lane_count: int = 4
@export var random_items: bool = true
@export var cyclic: bool = false
static var z_step: float = 1.0

@onready var path3d = $RoadPath3D
var road_mesh: RoadMesh
var barrier_left: RoadMesh
var barrier_right: RoadMesh
@onready var lanes_mesh: RoadLanesMesh = $RoadLanesMesh
var builders = []

var segments = []

func add_road_mesh(polygon, material):
	var node = RoadPath3D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("mobile") or OS.has_feature("web"):
		# Low poly on these platforms
		z_step = 3.0

	var r = road_width / 2.0
	var rb = r - (lanes_mesh.width / 2)
	var t = 0.25
	road_mesh = RoadMesh.new(
		path3d,
		PackedVector2Array([
			Vector2(-r, 0.0),
			Vector2(r, 0.0),
			Vector2(r, -t),
			Vector2(-r, -t),
			Vector2(-r, 0.0),
		]),
		ROAD_MAT,
		cyclic,
	)
	barrier_right = RoadMesh.new(
		path3d,
		PackedVector2Array([
			Vector2(rb, 0.0),
			Vector2(rb, barrier_shoulder),
			Vector2(rb + barrier_width, barrier_height),
			Vector2(rb + barrier_width, 0.0),
		]),
		NEON_MAT,
		cyclic,
	)
	barrier_left = RoadMesh.new(
		path3d,
		PackedVector2Array([
			Vector2(-rb - barrier_width, 0.0),
			Vector2(-rb - barrier_width, barrier_height),
			Vector2(-rb, barrier_shoulder),
			Vector2(-rb, 0.0),
		]),
		NEON_MAT,
		cyclic,
	)
	add_child(road_mesh)
	add_child(barrier_left)
	add_child(barrier_right)

	var lane_width = road_width / lane_count
	for i in range(1, lane_count):
		lanes_mesh.lane_offsets.append(-r + (i * lane_width))

	for child in get_children():
		if child.has_method("build"):
			builders.append(child)

	# Special handling of the first segment (always straight)
	add_segment(0.0, path3d.road_len)
	for i in range(segment_count - 1):
		extend(false)


func add_segment(old_len, new_len):
	var segment = RoadSegment.new()
	segment.process_thread_group = Node.PROCESS_THREAD_GROUP_MAIN_THREAD
	segment.length = new_len - old_len
	for builder in builders:
		segment.add_child(builder.build())
	if random_items:
		segment.random_item(path3d.curve, road_width, old_len, new_len)
	segments.append(segment)
	add_child(segment)


func extend(cut_first=true) -> float:
	var start_time = Time.get_ticks_msec()
	var cut_length: float = 0.0
	
	var old_len = path3d.extend_road()
	add_segment(old_len, path3d.road_len)
	
	if cut_first:
		cut_length = path3d.cut_first()
		for builder in builders:
			builder.current_offset -= cut_length
		segments.pop_front().queue_free()

	var end_time = Time.get_ticks_msec()
	var elapsed_time = end_time - start_time
	print("Time taken to build: %d milliseconds" % elapsed_time)
	return cut_length

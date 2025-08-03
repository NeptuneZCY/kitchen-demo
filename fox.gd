extends CharacterBody2D

@export var movement_speed: float = 50
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
var patrol_points: Array[Vector2] = []
var log: Array[String] = [
	"拿菜", "洗菜", "煮菜"
]
var current_point_index := 0

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	patrol_points = [
		get_node("../pos1").position,
		get_node("../pos2").position,
		get_node("../pos3").position
	]
	set_movement_target(patrol_points[current_point_index])
	
func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		print(log[current_point_index])
		current_point_index = (current_point_index + 1) % patrol_points.size()
		set_movement_target(patrol_points[current_point_index])
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

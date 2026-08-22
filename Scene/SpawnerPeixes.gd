extends Node2D

# Spawner separado para os peixes presos. Eles aparecem bem mais raramente
# que o lixo comum, já que cada um é um mini-desafio (sequência de puxões).

@export var cenas_peixes: Array[PackedScene] = []
@export var largura_area: float = 1330.0
@export var margem_lateral: float = 200.0
@export var altura_spawn: float = -120.0
@export var intervalo_min: float = 9.0
@export var intervalo_max: float = 16.0

var _timer: Timer

func _ready() -> void:
	randomize()
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)
	_reagendar()

func _reagendar() -> void:
	_timer.wait_time = randf_range(intervalo_min, intervalo_max)
	_timer.start()

func _on_timer_timeout() -> void:
	_spawnar_peixe()
	_reagendar()

func _spawnar_peixe() -> void:
	if cenas_peixes.is_empty():
		return

	var cena: PackedScene = cenas_peixes[randi() % cenas_peixes.size()]
	var instancia: Node2D = cena.instantiate()
	var x: float = randf_range(margem_lateral, largura_area - margem_lateral)
	instancia.position = Vector2(x, altura_spawn)
	add_child(instancia)

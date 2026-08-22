extends Node2D

# Faz chover lixo do céu infinitamente, sorteando entre as cenas configuradas
# (garrafa de cola, sacola de lixo, canudo) em posições X aleatórias.

@export var cenas_lixo: Array[PackedScene] = []
@export var largura_area: float = 1330.0
@export var margem_lateral: float = 60.0
@export var altura_spawn: float = -120.0

@export var quantidade_por_onda: int = 3

@export var velocidade_min_inicial: float = 190.0
@export var velocidade_max_inicial: float = 190.0
@export var velocidade_min_final: float = 260.0
@export var velocidade_max_final: float = 460.0

@export var intervalo_min_inicial: float = 1.4
@export var intervalo_max_inicial: float = 2.4
@export var intervalo_min_final: float = 0.3
@export var intervalo_max_final: float = 0.6

@export var tempo_caracteristico: float = 650.0

var _tempo_decorrido: float = 0.0
var _timer: Timer

func _ready() -> void:
	randomize()
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)
	_iniciar_proximo_spawn()

func _process(delta: float) -> void:
	_tempo_decorrido += delta

func _on_timer_timeout() -> void:
	if cenas_lixo.is_empty():
		_iniciar_proximo_spawn()
		return
		
	# Calcula o fator de dificuldade atual (0 a 1)
	var fator: float = 1.0 - exp(-_tempo_decorrido / tempo_caracteristico)
	
	# Calcula velocidades atuais baseadas na dificuldade
	var vel_min_atual: float = lerp(velocidade_min_inicial, velocidade_min_final, fator)
	var vel_max_atual: float = lerp(velocidade_max_inicial, velocidade_max_final, fator)
	
	# Cria a onda de lixo
	for i in range(quantidade_por_onda):
		var cena_sorteada: PackedScene = cenas_lixo.pick_random()
		var lixo_instancia = cena_sorteada.instantiate()
		
		# Garante que o X fique estritamente dentro da tela configurada
		var x_minimo: float = margem_lateral
		var x_maximo: float = largura_area - margem_lateral
		var x_aleatorio: float = randf_range(x_minimo, x_maximo)
		
		lixo_instancia.position = Vector2(x_aleatorio, altura_spawn)
		
		# Define uma velocidade aleatória para este lixo específico
		var velocidade_lixo: float = randf_range(vel_min_atual, vel_max_atual)
		if lixo_instancia.has_method("configurar_velocidade"):
			lixo_instancia.configurar_velocidade(velocidade_lixo)
			
		add_child(lixo_instancia)
		
	_iniciar_proximo_spawn()

func _iniciar_proximo_spawn() -> void:
	var fator: float = 1.0 - exp(-_tempo_decorrido / tempo_caracteristico)
	var int_min_atual: float = lerp(intervalo_min_inicial, intervalo_min_final, fator)
	var int_max_atual: float = lerp(intervalo_max_inicial, intervalo_max_final, fator)
	
	_timer.wait_time = randf_range(int_min_atual, int_max_atual)
	_timer.start()

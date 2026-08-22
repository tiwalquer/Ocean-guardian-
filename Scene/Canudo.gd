extends CharacterBody2D

# Velocidade inicial é sorteada quando o item nasce (o Spawner ajusta os
# valores min/max conforme a dificuldade progressiva do jogo).
@export var velocidade_queda_min: float = 110.0
@export var velocidade_queda_max: float = 190.0
@export var velocidade_rotacao: float = 2.0
@export var pontos: int = 10

var velocidade_queda: float
var direcao_rotacao: int = 1
var pousado: bool = false
var _tempo_travado: float = 0.0

func _ready() -> void:
	add_to_group("lixo")
	velocidade_queda = randf_range(velocidade_queda_min, velocidade_queda_max)
	direcao_rotacao = 1 if randf() > 0.5 else -1

func _physics_process(delta: float) -> void:
	if pousado:
		return

	var y_antes: float = position.y

	# Movimento por física de verdade: agora colide com o chão e com o
	# lixo que já pousou, em vez de simplesmente "teletransportar" a posição.
	velocity.y = velocidade_queda
	move_and_slide()

	# Faz o canudo girar na queda (para de girar assim que pousa)
	rotation += velocidade_rotacao * direcao_rotacao * delta

	if is_on_floor():
		_pousar()
		return

	# Segurança extra: se o item ficar "travado" (colidindo com outro lixo
	# e sem conseguir cair de verdade) por meio segundo sem tocar o chão,
	# considera ele pousado mesmo assim — evita ficar flutuando parado pra
	# sempre, sem poder ser cortado nem contar pro limite.
	if position.y - y_antes < 1.0:
		_tempo_travado += delta
		if _tempo_travado > 0.5:
			_pousar()
			return
	else:
		_tempo_travado = 0.0

	# Segurança: se por algum motivo passar muito da tela, remove
	if position.y > 1000:
		queue_free()

func _pousar() -> void:
	pousado = true
	velocity = Vector2.ZERO
	rotation = randf_range(-0.3, 0.3)
	GameManager.registrar_pouso()

# Chamada pela LaminaMouse quando o mouse passa por cima.
# Só funciona enquanto o lixo ainda está caindo — depois que pousa no chão,
# só o super da tartaruga (tecla B) consegue limpar.
func cortar() -> void:
	if pousado:
		return
	GameManager.adicionar_pontos(pontos)
	queue_free()

# Chamada pelo GameManager quando a tartaruga usa o super
func limpar_pelo_super() -> void:
	if pousado:
		GameManager.registrar_remocao_do_chao()
	queue_free()

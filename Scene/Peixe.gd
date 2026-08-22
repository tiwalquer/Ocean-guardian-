extends CharacterBody2D

# PEIXE PRESO
# Cai do céu como o resto do lixo, mas para ser removido o jogador precisa
# "puxar" o mouse (arrastar) na direção certa, 3 vezes seguidas, seguindo
# uma sequência sorteada e mostrada na tela por uma seta fixa (não gira
# junto com o peixe).
#
# - Acertar as 3 direções -> peixe é libertado (troca de sprite, dá pontos
#   e nada embora).
# - Errar uma direção NÃO é fatal: não mostra nada, só deixa o jogador
#   tentar de novo na hora, sem limite, enquanto o peixe ainda estiver caindo.
# - Só quando o peixe encosta no chão sem ter terminado a sequência é que
#   ele fica "emperrado" de vez: conta como lixo pra contagem dos 20
#   (game over), mas o super da tartaruga NÃO consegue removê-lo — só
#   reiniciando a partida.

@export var velocidade_queda_min: float = 90.0
@export var velocidade_queda_max: float = 150.0
@export var velocidade_rotacao: float = 0.6
@export var pontos: int = 20

# Atribuído em cada cena (peixe_amarelo.tscn / peixe_azul.tscn) com os
# frames do peixe já solto (ex: PeixeAmareloLivre)
@export var frames_livre: SpriteFrames
@export var escala_preso: float = 1.0
@export var escala_livre: float = 1.0

# Raio (em pixels) em volta do peixe onde o mouse precisa estar para os
# puxões serem detectados.
@export var raio_interacao: float = 170.0

const DIRECOES: Array[String] = ["cima", "baixo", "esquerda", "direita"]
# Quanto o mouse precisa se mover pra contar como um "puxão" de verdade
# (bem maior que antes, pra só passar o mouse por cima não disparar nada)
const LIMIAR_PUXAO: float = 95.0
# O eixo dominante precisa ser bem mais forte que o outro, senão o
# movimento é ignorado (evita errar por um gesto quase na diagonal)
const DOMINANCIA_MINIMA: float = 1.35
const QUANTIDADE_PASSOS: int = 3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var seta_direcao: Node2D = $SetaDirecao

var velocidade_queda: float
var direcao_rotacao: int = 1
var pousado: bool = false
var libertado: bool = false
var _tempo_travado: float = 0.0
var acumulador_mouse: Vector2 = Vector2.ZERO
var sequencia: Array[String] = []
var passo_atual: int = 0

func _ready() -> void:
	velocidade_queda = randf_range(velocidade_queda_min, velocidade_queda_max)
	direcao_rotacao = 1 if randf() > 0.5 else -1

	# Aplica a escala do peixe ainda preso (um pouco menor que antes).
	sprite.scale = Vector2(escala_preso, escala_preso)

	# A seta não deve girar/mover junto com o peixe (fica em transform
	# próprio, só copiamos a posição a cada frame no _physics_process)
	seta_direcao.top_level = true

	_gerar_sequencia()
	_atualizar_seta()
	_atualizar_posicao_seta()

func _gerar_sequencia() -> void:
	sequencia.clear()
	for i in range(QUANTIDADE_PASSOS):
		sequencia.append(DIRECOES[randi() % DIRECOES.size()])

func _atualizar_seta() -> void:
	if passo_atual < sequencia.size():
		seta_direcao.apontar_para(sequencia[passo_atual])

func _atualizar_posicao_seta() -> void:
	seta_direcao.global_position = global_position

func _physics_process(delta: float) -> void:
	if pousado or libertado:
		return

	var y_antes: float = position.y

	velocity.y = velocidade_queda
	move_and_slide()
	rotation += velocidade_rotacao * direcao_rotacao * delta

	_atualizar_posicao_seta()

	if is_on_floor():
		_pousar()
		return

	# Segurança extra: se o peixe ficar "travado" (colidindo com outro lixo
	# e sem conseguir cair de verdade) por meio segundo sem tocar o chão,
	# considera ele pousado (emperrado) mesmo assim — evita ficar
	# flutuando parado pra sempre, sem poder ser cortado nem interagido.
	if position.y - y_antes < 1.0:
		_tempo_travado += delta
		if _tempo_travado > 0.5:
			_pousar()
			return
	else:
		_tempo_travado = 0.0

	if position.y > 1000:
		queue_free()

func _pousar() -> void:
	pousado = true
	velocity = Vector2.ZERO
	seta_direcao.esconder()
	GameManager.registrar_pouso()

# Usamos _input (não _unhandled_input) pra garantir que o movimento do
# mouse seja sempre recebido, mesmo que algum elemento de UI esteja por cima.
func _input(event: InputEvent) -> void:
	if libertado or pousado:
		return
	if not (event is InputEventMouseMotion):
		return

	var perto: bool = get_global_mouse_position().distance_to(global_position) <= raio_interacao
	if not perto:
		acumulador_mouse = Vector2.ZERO
		return

	acumulador_mouse += event.relative
	if acumulador_mouse.length() >= LIMIAR_PUXAO:
		var vetor: Vector2 = acumulador_mouse
		acumulador_mouse = Vector2.ZERO
		_processar_puxao(vetor)

func _processar_puxao(vetor: Vector2) -> void:
	var direcao_feita: String = _vetor_para_direcao(vetor)
	if direcao_feita == "":
		# Movimento ambíguo (quase na diagonal) -- ignora, não conta como erro
		return

	var direcao_esperada: String = sequencia[passo_atual]

	if direcao_feita == direcao_esperada:
		passo_atual += 1
		if passo_atual >= sequencia.size():
			_libertar()
		else:
			_atualizar_seta()
	# Errar a direção não é mais mostrado com um X: o jogador só tenta de
	# novo na hora, sem nenhuma penalidade visual (a seta continua mostrando
	# a direção certa esperada).

# Retorna "" quando o movimento é ambíguo demais (nem claramente horizontal
# nem claramente vertical) pra dar uma margem de erro maior ao jogador.
func _vetor_para_direcao(vetor: Vector2) -> String:
	var ax: float = abs(vetor.x)
	var ay: float = abs(vetor.y)

	if ax > ay * DOMINANCIA_MINIMA:
		return "direita" if vetor.x > 0.0 else "esquerda"
	elif ay > ax * DOMINANCIA_MINIMA:
		return "baixo" if vetor.y > 0.0 else "cima"
	else:
		return ""

func _libertar() -> void:
	libertado = true
	seta_direcao.esconder()
	GameManager.adicionar_pontos(pontos)

	if frames_livre != null:
		sprite.sprite_frames = frames_livre
		sprite.scale = Vector2(escala_livre, escala_livre)
		sprite.play("default")

	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)

	# Sorteia um lado (esquerda ou direita) e nada pra fora da tela por ali,
	# virando a sprite pro lado certo.
	var lado: int = 1 if randf() > 0.5 else -1
	sprite.flip_h = lado < 0

	var alvo_x: float = 1500.0 if lado > 0 else -150.0
	var velocidade_nado: float = 460.0
	var duracao: float = abs(alvo_x - position.x) / velocidade_nado

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "rotation", 0.0, 0.4)
	tween.parallel().tween_property(self, "position:x", alvo_x, duracao)
	tween.parallel().tween_property(self, "position:y", position.y - 40.0, min(duracao, 1.2))
	tween.chain().tween_callback(queue_free)

# Chamada pela LaminaMouse ao encostar no peixe (não faz nada — o peixe só
# é removido com a sequência de puxões, nunca por um corte simples).
func cortar() -> void:
	pass

# O super da tartaruga NÃO tem efeito sobre peixes, presos ou emperrados.
func limpar_pelo_super() -> void:
	pass

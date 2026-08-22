extends CanvasLayer

@onready var label_pontos: Label = $Control/LabelPontos
@onready var label_super: Label = $Control/LabelSuper
@onready var label_lixo: Label = $Control/LabelLixo
@onready var painel_game_over: Control = $Control/PainelGameOver
@onready var label_pontuacao_final: Label = $Control/PainelGameOver/CaixaGameOver/LabelPontuacaoFinal
@onready var botao_reiniciar: Button = $Control/PainelGameOver/CaixaGameOver/BotaoReiniciar

func _ready() -> void:
	GameManager.pontos_atualizados.connect(_on_pontos_atualizados)
	GameManager.super_atualizado.connect(_on_super_atualizado)
	GameManager.lixo_no_chao_atualizado.connect(_on_lixo_no_chao_atualizado)
	GameManager.jogo_terminado.connect(_on_jogo_terminado)
	botao_reiniciar.pressed.connect(_on_botao_reiniciar_pressed)

	painel_game_over.visible = false

	_on_pontos_atualizados(GameManager.pontos)
	_on_super_atualizado(GameManager.cargas_super)
	_on_lixo_no_chao_atualizado(GameManager.lixo_pousado)

func _on_pontos_atualizados(pontos: int) -> void:
	label_pontos.text = "Pontos: %d" % pontos

func _on_super_atualizado(cargas: int) -> void:
	if cargas > 0:
		label_super.text = "SUPER PRONTO! Aperte B (x%d)" % cargas
	else:
		label_super.text = "Super em: %d pts" % GameManager.pontos_faltando_para_super()

func _on_lixo_no_chao_atualizado(quantidade: int) -> void:
	label_lixo.text = "Lixo no chão: %d/%d" % [quantidade, GameManager.LIMITE_LIXO_NO_CHAO]

func _on_jogo_terminado() -> void:
	label_pontuacao_final.text = "Pontuação final: %d" % GameManager.pontos
	painel_game_over.visible = true
	get_tree().paused = true

func _on_botao_reiniciar_pressed() -> void:
	get_tree().paused = false
	GameManager.reiniciar()
	get_tree().reload_current_scene()

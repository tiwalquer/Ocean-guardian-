extends Node

# GameManager: controla a pontuação, o "super" da tartaruga e o game over.
# Registrado como Autoload (singleton), acessível de qualquer script como "GameManager".

signal pontos_atualizados(pontos: int)
signal super_atualizado(cargas: int)
signal super_usado
signal lixo_no_chao_atualizado(quantidade: int)
signal jogo_terminado

const PONTOS_PARA_SUPER: int = 200
const LIMITE_LIXO_NO_CHAO: int = 20

var pontos: int = 0
var cargas_super: int = 0
var pontos_usados_no_super: int = 0

# Quantidade de lixo atualmente parado/empilhado no chão
var lixo_pousado: int = 0

# Fica false assim que o game over acontece, pra não disparar de novo
var jogo_ativo: bool = true

func registrar_pouso() -> void:
	if not jogo_ativo:
		return

	lixo_pousado += 1
	lixo_no_chao_atualizado.emit(lixo_pousado)

	if lixo_pousado >= LIMITE_LIXO_NO_CHAO:
		_game_over()

func registrar_remocao_do_chao() -> void:
	lixo_pousado = max(0, lixo_pousado - 1)
	lixo_no_chao_atualizado.emit(lixo_pousado)

func adicionar_pontos(valor: int) -> void:
	if not jogo_ativo:
		return

	pontos += valor
	pontos_atualizados.emit(pontos)
	_verificar_nova_carga_super()

func _verificar_nova_carga_super() -> void:
	var cargas_disponiveis: int = int(float(pontos - pontos_usados_no_super) / PONTOS_PARA_SUPER)
	if cargas_disponiveis > cargas_super:
		cargas_super = cargas_disponiveis
		super_atualizado.emit(cargas_super)

# Chamado quando o jogador aperta "B". Retorna true se o super foi ativado.
func usar_super() -> bool:
	if not jogo_ativo or cargas_super <= 0:
		return false

	cargas_super -= 1
	pontos_usados_no_super += PONTOS_PARA_SUPER
	super_atualizado.emit(cargas_super)
	super_usado.emit()
	_limpar_todo_lixo()
	return true

func _limpar_todo_lixo() -> void:
	for lixo in get_tree().get_nodes_in_group("lixo"):
		if lixo.has_method("limpar_pelo_super"):
			lixo.limpar_pelo_super()

func _game_over() -> void:
	jogo_ativo = false
	jogo_terminado.emit()

# Quantos pontos faltam para a próxima carga do super (útil para a UI)
func pontos_faltando_para_super() -> int:
	var progresso: int = (pontos - pontos_usados_no_super) % PONTOS_PARA_SUPER
	return PONTOS_PARA_SUPER - progresso

# Reseta tudo para começar uma nova partida
func reiniciar() -> void:
	pontos = 0
	cargas_super = 0
	pontos_usados_no_super = 0
	lixo_pousado = 0
	jogo_ativo = true
	pontos_atualizados.emit(pontos)
	super_atualizado.emit(cargas_super)
	lixo_no_chao_atualizado.emit(lixo_pousado)

extends Node2D

# Seta desenhada na tela (não é sprite/imagem — é desenhada por código),
# no estilo "chevron duplo" (>>>>). Fica com "top_level = true" (setado
# pelo Peixe.gd), então segue a POSIÇÃO do peixe mas nunca gira junto com
# ele — a direção mostrada fica sempre fixa e legível.

@export var comprimento: float = 190.0
@export var altura_chevron: float = 46.0
@export var quantidade_chevrons: int = 4
@export var espessura_traco: float = 9.0
@export var cor_preenchimento: Color = Color(1, 1, 1, 1)
@export var cor_contorno: Color = Color(0, 0, 0, 1)

func _draw() -> void:
	_desenhar_chevrons()

func _desenhar_chevrons() -> void:
	var largura_total: float = comprimento
	var passo: float = largura_total / float(quantidade_chevrons + 1)
	var largura_chevron: float = passo * 1.7

	for i in range(quantidade_chevrons):
		var centro_x: float = -largura_total / 2.0 + passo * (i + 1)
		_desenhar_um_chevron(Vector2(centro_x, 0.0), largura_chevron, altura_chevron)

func _desenhar_um_chevron(centro: Vector2, largura: float, altura: float) -> void:
	var t: float = espessura_traco
	var meia_altura: float = altura / 2.0

	var pontos := PackedVector2Array([
		centro + Vector2(-largura / 2.0, -meia_altura),
		centro + Vector2(largura / 2.0, 0.0),
		centro + Vector2(-largura / 2.0, meia_altura),
		centro + Vector2(-largura / 2.0 + t * 1.4, meia_altura),
		centro + Vector2(largura / 2.0 - t * 1.4, 0.0),
		centro + Vector2(-largura / 2.0 + t * 1.4, -meia_altura),
	])

	draw_colored_polygon(pontos, cor_preenchimento)
	draw_polyline(pontos, cor_contorno, 3.0, true)
	draw_line(pontos[0], pontos[5], cor_contorno, 3.0)

func apontar_para(direcao: String) -> void:
	match direcao:
		"direita":
			rotation = 0.0
		"baixo":
			rotation = PI / 2.0
		"esquerda":
			rotation = PI
		"cima":
			rotation = -PI / 2.0
	visible = true
	queue_redraw()

func esconder() -> void:
	visible = false

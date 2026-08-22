extends Sprite2D


const PASTA: String = "res://SPRIT_GODOT/FundoDoMar/"

const ARQUIVOS: Array[String] = [
	"fundoMar1.png",
	"FundoMar2.png",
	"FundoMar3.png",
	"FundoMar4.png",
	"FundoMar5.png",
	"FundoMar6.png",
	"FundoMar7.png",
	"FundoMar8.png",
	"FundoMar9.png",
	"FundoMar10.png",
	"FundoMar11.png",
	"FundoMar12.png",
]

const INTERVALO_TROCA: float = 20.0

const TAMANHO_TELA: Vector2 = Vector2(1330.0, 750.0)

var _texturas: Array[Texture2D] = []
var _indice: int = 0

func _ready() -> void:
	
	z_index = -100
	centered = true
	top_level = true
	position = TAMANHO_TELA / 2.0

	for nome_arquivo in ARQUIVOS:
		var caminho: String = PASTA + nome_arquivo
		if ResourceLoader.exists(caminho):
			var tex: Texture2D = load(caminho)
			if tex != null:
				_texturas.append(tex)

	if _texturas.is_empty():
		return

	_aplicar_textura(_texturas[0])

	var timer: Timer = Timer.new()
	timer.wait_time = INTERVALO_TROCA
	timer.autostart = true
	timer.timeout.connect(_trocar_para_proxima)
	add_child(timer)


func _aplicar_textura(tex: Texture2D) -> void:
	texture = tex
	var tamanho_textura: Vector2 = tex.get_size()
	if tamanho_textura.x > 0.0 and tamanho_textura.y > 0.0:
		var fator: float = max(
			TAMANHO_TELA.x / tamanho_textura.x,
			TAMANHO_TELA.y / tamanho_textura.y
		)
		scale = Vector2(fator, fator)

func _trocar_para_proxima() -> void:
	if _texturas.is_empty():
		return
	_indice = (_indice + 1) % _texturas.size()
	_aplicar_textura(_texturas[_indice])

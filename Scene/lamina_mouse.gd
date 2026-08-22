extends Area2D

# Segue o mouse na tela e corta qualquer lixo que tocar
# (basta passar o mouse por cima, sem precisar clicar).

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("cortar"):
		body.cortar()

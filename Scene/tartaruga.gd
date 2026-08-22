extends CharacterBody2D


const SPEED = 420.0

# Limites horizontais da tela (a tartaruga não passa dessas bordas)
@export var limite_esquerdo: float = 40.0
@export var limite_direito: float = 1290.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# mantém a tartaruga presa no chão
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Segue a posição X do mouse, sempre no chão (parte de baixo da tela)
	var alvo_x: float = clamp(get_global_mouse_position().x, limite_esquerdo, limite_direito)
	var diferenca: float = alvo_x - global_position.x

	if abs(diferenca) > 2.0:
		velocity.x = clamp(diferenca * 8.0, -SPEED, SPEED)
		if animated_sprite != null:
			animated_sprite.flip_h = diferenca < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	# Aperta "B" para usar o super da tartaruga (limpa todo o lixo da tela)
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_B:
		if GameManager.usar_super():
			_efeito_super()


func _efeito_super() -> void:
	if animated_sprite == null:
		return
	var tween := create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1.6, 1.6, 1.6), 0.1)
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1), 0.3)

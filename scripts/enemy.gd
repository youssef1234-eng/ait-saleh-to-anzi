extends CharacterBody2D

var speed = 30
var is_attacking = false
var is_dead = false
var player: Node2D
var attack_range = 20.0
var last_direction = Vector2.DOWN

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):

	if not player or is_attacking or is_dead:
		return
	
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	
	if distance < attack_range:
		await attack(to_player.normalized())
	else:
		var direction = to_player.normalized()
		last_direction = direction
		velocity = direction * speed
		move_and_slide()
		play_walk_anim(direction)

func attack(direction: Vector2) -> void:
	if is_dead or is_attacking:
		return

	is_attacking = true
	play_attack_anim(direction)

	await sprite.animation_finished

	# ✅ تحقق مرة أخرى بعد الأنميشن: العدو لا يزال حي واللاعب موجود
	if not is_dead and player and player.has_method("take_hit"):
		await player.take_hit()

	is_attacking = false

func die() -> void:
	if is_dead:
		return
	is_dead = true
	sprite.play("death")
	collision_shape.disabled = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.play("death_enemy")
	move_and_slide()
	
	await sprite.animation_finished

	print("kill enemy")

func play_walk_anim(dir: Vector2):
	if dir.y < -0.5:
		if dir.x > 0.5:
			sprite.play("ne_walk")
		elif dir.x < -0.5:
			sprite.play("wn_walk")
		else:
			sprite.play("n_walk")
	elif dir.y > 0.5:
		if dir.x > 0.5:
			sprite.play("se_walk")
		elif dir.x < -0.5:
			sprite.play("sw_walk")
		else:
			sprite.play("s_walk")
	else:
		if dir.x > 0:
			sprite.play("e_walk")
		elif dir.x < 0:
			sprite.play("w_walk")

func play_attack_anim(dir: Vector2):
	if dir.y < -0.5:
		if dir.x > 0.5:
			sprite.play("attack_ne")
		elif dir.x < -0.5:
			sprite.play("attack_nw")
		else:
			sprite.play("attack_n")
	elif dir.y > 0.5:
		if dir.x > 0.5:
			sprite.play("attack_se")
		elif dir.x < -0.5:
			sprite.play("attack_sw")
		else:
			sprite.play("attack_s")
	else:
		if dir.x > 0:
			sprite.play("attack_e")
		elif dir.x < 0:
			sprite.play("attack_w")

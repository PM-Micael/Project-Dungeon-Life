extends Entity

# Maximum hits blocked per star level (e.g. star 1 = 1 block, star 2 = 2, etc.)
# Adjust BLOCK_CAP_PER_STAR to tune how many hits each star level blocks.
const BLOCK_CAP_PER_STAR: int = 1

const DAMAGE_BLOCKED_PER_HIT: int = 999999

# ── State ────────────────────────────────────────────────────────────────────
var _in_stance: bool = false
var _hits_remaining: int = 0
var _attacks_blocked: int = 0

@onready var audio_stream_player: AudioStreamPlayer = $Components/WeaponComponent/AudioStreamPlayer
@onready var punch_sound: AudioStreamPlayer = $Components/WeaponComponent/PunchSound

func _init() -> void:
	id = "crag_chunk"

func _ready() -> void:
	name = "crag_chunk"
	display_name = "Crag Chunk"
	weapon_component.use_weapon_skill.connect(_weapon_skill)

func _weapon_skill(_targets: Array[Entity]) -> void:
	var wearer: Entity = weapon_component.entity_holding_weapon
	if not is_instance_valid(wearer) or _in_stance:
		return
	
	audio_stream_player.play()
	
	var star: int = weapon_component.star_level
	_hits_remaining = BLOCK_CAP_PER_STAR * star
	_attacks_blocked = 0
	_in_stance = true

	wearer.is_stunned = true

	# Hook into damage to intercept incoming hits
	wearer.health_component.pre_calculate_damage.connect(_on_damage_incoming)

func _on_damage_incoming(attacker: Entity, amount: int, _is_crit: bool) -> void:
	var wearer: Entity = weapon_component.entity_holding_weapon
	if not is_instance_valid(wearer):
		_end_stance(wearer)
		return

	# Ignore DoT sources (Burning etc.) — they come from the effect_component,
	# not a living attacker. We identify them by checking if attacker is the
	# wearer themselves or null (DoTs pass the target as the attacker).
	if attacker == null or attacker == wearer:
		return

	# Block the hit
	wearer.health_component.final_damage_taken_amount = max(
		0, amount - DAMAGE_BLOCKED_PER_HIT)
	_attacks_blocked += 1
	_hits_remaining -= 1

	print("Crag Chunk: Hit blocked! ("
		+ str(_hits_remaining) + " remaining)")

	if _hits_remaining <= 0:
		_end_stance(wearer)

func _end_stance(wearer: Entity) -> void:
	if not _in_stance:
		return
	_in_stance = false

	if is_instance_valid(wearer):
		wearer.is_stunned = false # Possible bug... or feature o.O

		# Disconnect the damage hook
		if wearer.health_component.pre_calculate_damage.is_connected(_on_damage_incoming):
			wearer.health_component.pre_calculate_damage.disconnect(_on_damage_incoming)

		# Retaliation strike — attack damage × number of hits successfully blocked
		if _attacks_blocked > 0 and wearer.targeting_component != null:
			var target: Entity = wearer.targeting_component.target
			if is_instance_valid(target) and target.health_component != null:
				var retaliation_damage: int = \
					wearer.attack_component.get_total_attack_damage() * _attacks_blocked
				target.health_component.take_damage_flat(
					wearer, retaliation_damage, false)
				print("Crag Chunk: Retaliation! "
					+ str(retaliation_damage) + " damage ("
					+ str(_attacks_blocked) + " block(s) × "
					+ str(wearer.attack_component.get_total_attack_damage()) + ")")
				punch_sound.play()
		else:
			print("Crag Chunk: Stance ended, no hits were blocked — no retaliation.")

	_attacks_blocked = 0

extends Entity

# Each Burning debuff absorbed grants this much Attack Up (stacks additively)
const ATTACK_UP_PER_BURN: float = 0.10
const ATTACK_UP_DURATION: float = 5.0

func _init() -> void:
	id = "heat_seeker"

func _ready() -> void:
	name = "heat_seeker"
	display_name = "Heat Seeker"
	weapon_component.use_weapon_skill.connect(_weapon_skill)

func _weapon_skill(_targets: Array[Entity]):
	weapon_component.weapon_skill_sound.play()
	
	var wearer: Entity = weapon_component.entity_holding_weapon

	# Collect every Burning debuff present on ALL entities on the board
	var burn_count: int = 0
	var all_entities: Array[Node] = get_tree().get_nodes_in_group("Team 1") \
		+ get_tree().get_nodes_in_group("Team 2")

	for entity in all_entities:
		if entity is Entity and entity.effect_component != null:
			var to_remove: Array[Debuff] = []
			for debuff in entity.effect_component.active_debuffs:
				if debuff.id == "burning":
					to_remove.append(debuff)

			for debuff in to_remove:
				entity.effect_component._remove_debuff(debuff)
				burn_count += 1

	if burn_count == 0:
		return

	# Grant one Attack Up buff per Burning absorbed (each carries a 10% boost)
	if wearer.effect_component == null:
		return

	for i in range(burn_count):
		var atk_up := AttackUp.new()
		atk_up.attack_multiplier = ATTACK_UP_PER_BURN
		atk_up.duration = ATTACK_UP_DURATION
		# Force separate instances so each ticks down independently
		wearer.effect_component.add_buff(atk_up, wearer)

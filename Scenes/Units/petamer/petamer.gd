extends Unit

@export_category("Stats")
@export var max_health: int = 10

func _init() -> void:
	id = "unit_petamer"
	passive_description = "Placing a debuff on an enemy sneds Wrath out to attack the target.
		Damage is based on the amount of debuffs on the target.
		Placing a Buff on an ally sends out Soothe to heal the target.
		Healing is based on buffs on the target"

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("petamer", "Petamer", "Team 1", "Team 2")
	_connect_to_all_units()

func _set_stats():
	health_component.set_stats(max_health)

func _connect_to_all_units():
	for entity in get_tree().get_nodes_in_group("units"):
		if entity.debuff_component != null:
			entity.debuff_component.debuff_applied.connect(_on_debuff_applied)
		if entity.buff_component != null:
			entity.buff_component.buff_applied.connect(_on_buff_applied)

func _on_debuff_applied(target: Entity):
	if target.hostile_team == hostile_team:
		_send_familiar(target, false)

func _on_buff_applied(target: Entity):
	if target.hostile_team != hostile_team:
		_send_familiar(target, true)

func _send_familiar(target: Entity, is_heal: bool):
	if is_heal:
		var buff_count = target.buff_component.active_buffs.size()
		target.health_component.heal(buff_count)
		print("Soothe sent to " + target.display_name)
	else:
		var debuff_count = target.debuff_component.active_debuffs.size()
		target.health_component.take_damage_flat(debuff_count, self)
		print("Wrath sent to " + target.display_name)

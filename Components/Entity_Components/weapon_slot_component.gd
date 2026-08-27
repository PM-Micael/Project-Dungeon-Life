extends Node2D
class_name WeaponSlotComponent

signal weapon_changed(weapon: Entity)

# Lazy getters, not @onready: the slot's contents change on every equip, and the
# entity may still be detached from the tree when these are read.
var weapon: Entity:
	get:
		return get_child(0) as Entity if get_child_count() > 0 else null

var parent_entity: Entity:
	get:
		return get_parent().get_parent() as Entity

## Equips new_weapon and returns the weapon that was removed (null if the slot was
## empty). The caller owns the returned node - it is detached, not freed.
func equip(new_weapon: Entity) -> Entity:
	var old_weapon: Entity = weapon
	if old_weapon != null:
		remove_child(old_weapon)
	if new_weapon != null:
		add_child(new_weapon)

	weapon_changed.emit(new_weapon)
	return old_weapon

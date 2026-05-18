extends Node

const LOOT_POOLS: Dictionary = {
	"putrid_layers": {
		"common": [
			{ "item_id": "splinter", "min_star": 1, "max_star": 1 },
			{ "item_id": "rumble_gloves", "min_star": 1, "max_star": 1 },
			{ "item_id": "cursed_lantern", "min_star": 1, "max_star": 1 },
		],
	}
}

const RARITY_WEIGHTS: Dictionary = {
	"common":   60,
	"uncommon": 0,
	"rare":     0,
}

const LOOT_COUNT: int = 1

func roll_loot(zone: String, _room_number: int) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var picked_ids: Array[String] = []

	for i in range(LOOT_COUNT):
		var rarity: String = _roll_rarity()
		var item = _pick_from_rarity(zone, rarity, picked_ids)
		if item.is_empty():
			continue
		var star: int = randi_range(item["min_star"], item["max_star"])
		results.append({ "item_id": item["item_id"], "star_level": star, "item_type": "weapon" })
		picked_ids.append(item["item_id"])

	return results

func _roll_rarity() -> String:
	var total: int = 0
	for w in RARITY_WEIGHTS.values():
		total += w

	var roll: int = randi() % total
	var cumulative: int = 0
	for rarity in RARITY_WEIGHTS:
		cumulative += RARITY_WEIGHTS[rarity]
		if roll < cumulative:
			return rarity

	return "common"

func _pick_from_rarity(zone: String, rarity: String, exclude_ids: Array[String] = []) -> Dictionary:
	var pool: Array = LOOT_POOLS.get(zone, {}).get(rarity, []).filter(func(e): return not exclude_ids.has(e["item_id"]))
	if pool.is_empty():
		return {}
	return pool[randi() % pool.size()]

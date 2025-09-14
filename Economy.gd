# GameEconomy.gd - Make this an Autoload singleton
# Project Settings > Autoload > Add this script as "GameEconomy"
extends Node

var money: int = 100
var max_money: int = 99999

# Signals for UI updates
signal money_changed(new_amount: int)
signal insufficient_funds(cost: int, current_money: int)

func add_money(amount: int):
	money = min(money + amount, max_money)
	money_changed.emit(money)
	print("Added ", amount, " money. Total: ", money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		print("Spent ", amount, " money. Remaining: ", money)
		return true
	else:
		insufficient_funds.emit(amount, money)
		print("Not enough money! Need: ", amount, ", Have: ", money)
		return false

func can_afford(amount: int) -> bool:
	return money >= amount

func get_money() -> int:
	return money

func set_money(amount: int):
	money = clamp(amount, 0, max_money)
	money_changed.emit(money)

# Save/Load functions for persistence
func save_economy_data() -> Dictionary:
	return {
		"money": money
	}

func load_economy_data(data: Dictionary):
	money = data.get("money", money)
	money_changed.emit(money)

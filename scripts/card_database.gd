class_name CardDatabase

const CARDS = {
	"goblin": {
		"type": "monster",
		"name": "Goblin",
		"energy_cost": 1,
		"attack": 1,
		"health": 1,
		"description": "Tropa goblin simples.",
		"ability": "nothing"
 	},
	"hobgoblin": {
		"type": "monster",
		"name": "Hobgoblin",
		"energy_cost": 2,
		"attack": 2,
		"health": 3,
		"description": "Entra em modo berserk.",
		"ability": "berserk"
  	},
	"healing_spell": {
		"type": "spell",
		"name": "Cura Divina",
		"energy_cost": 3,
		"description": "Restaura 5 de vida.",
		"effect": "heal_5"
  	}
}

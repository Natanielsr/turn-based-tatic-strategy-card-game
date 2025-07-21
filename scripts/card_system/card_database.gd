class_name CardDatabase

const CARDS = {
	"rat": {
		"card_id": "rat",
		"type": "monster",
		"name": "Rat",
		"energy_cost": 1,
		"attack": 1,
		"health": 1,
		"description": "Just a smelly mouse",
		"ability": ""
  	},
	"spider": {
		"card_id": "spider",
		"type": "monster",
		"name": "Spider",
		"energy_cost": 2,
		"attack": 1,
		"health": 2,
		"description": "Posion: Causes poisoning against the opponent when it attacks",
		"ability": "poison"
  	},
	"wolf": {
		"card_id": "wolf",
		"type": "monster",
		"name": "Wolf",
		"energy_cost": 3,
		"attack": 2,
		"health": 3,
		"description": "bites the opponent",
		"ability": ""
  	},
	"goblin": {
		"card_id": "goblin",
		"type": "monster",
		"name": "Goblin",
		"energy_cost": 4,
		"attack": 2,
		"health": 4,
		"description": "Bleeding: Causes bleeding against the opponent when it attacks",
		"ability": "bleeding"
 	},
	"hobgoblin": {
		"card_id": "hobgoblin",
		"type": "monster",
		"name": "Hobgoblin",
		"energy_cost": 5,
		"attack": 4,
		"health": 5,
		"description": "Berserk: Increases attack when you are injured",
		"ability": ""
  	},
	"healing_spell": {
		"card_id": "healing_spell",
		"type": "spell",
		"name": "Cura Divina",
		"energy_cost": 3,
		"description": "Restaura 5 de vida.",
		"effect": "heal_5"
  	}
}

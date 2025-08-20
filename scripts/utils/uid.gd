class_name Uid
static func generate_id(card_id, faction : Entity.EntityFaction):
	return str(card_id + "_"+Entity.EntityFaction.keys()[faction] +"_"+str(randi()))

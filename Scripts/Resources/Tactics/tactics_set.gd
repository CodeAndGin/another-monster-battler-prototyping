extends Resource
class_name TacticsSet

@export var default_set_is_A = true

##While ideally these will be defined through in game menus, for now, each element of the dictionary that represents an in use line should be
##of the Tactic resource class, with the priority order of "First" through "Fifth" for Action lines and "First reaction" through "Fifth reaction"
##for Reaction lines
@export var setA = \
{
	"First": null,
	"Second": null,
	"Third": null,
	"Fourth": null,
	"Fifth": null,
	"First reaction": null,
	"Second reaction": null,
	"Third reaction": null,
	"Fourth reaction": null,
	"Fifth reaction": null
}

##While ideally these will be defined through in game menus, for now, each element of the dictionary that represents an in use line should be
##of the Tactic resource class, with the priority order of "First" through "Fifth" for Action lines and "First reaction" through "Fifth reaction"
##for Reaction lines
@export var setB = \
{
	"First": null,
	"Second": null,
	"Third": null,
	"Fourth": null,
	"Fifth": null,
	"First reaction": null,
	"Second reaction": null,
	"Third reaction": null,
	"Fourth reaction": null,
	"Fifth reaction": null
}

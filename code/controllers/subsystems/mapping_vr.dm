//
// Mapping subsystem handles initialization of random map elements at server start
// On VOREStation that means loading our random roundstart engine!
//
SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = INIT_ORDER_MAPPING
	flags = SS_NO_FIRE

	var/obj/effect/landmark/engine_loader/engine_loader

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT // Make extra sure we don't initialize twice.

/datum/controller/subsystem/mapping/Initialize(timeofday)
	loadEngine()
	// TODO - This probably should be here
	// // Pick a random away mission.
	// createRandomZlevel()
	// Mining generation probably should be here too
	// TODO - Other stuff related to maps and areas could be moved here too.  Look at /tg
	..()

/datum/controller/subsystem/mapping/proc/loadEngine()
	if(!engine_loader)
		return // Seems this map doesn't need an engine loaded.

	var/turf/T = get_turf(engine_loader)
	if(!isturf(T))
		to_world_log("[log_info_line(engine_loader)] not on a turf! Cannot place engine template.")
		return

	// Choose an engine type
	var/datum/map_template/engine/chosen_type = null
	if (LAZYLEN(config.engine_map))
		var/chosen_name = pick(config.engine_map)
		chosen_type = map_templates[chosen_name]
		if(!istype(chosen_type))
			error("Configured engine map [chosen_name] is not a valid engine map name!")
	if(!istype(chosen_type))
		var/list/engine_types = list()
		for(var/map in map_templates)
			var/datum/map_template/engine/MT = map_templates[map]
			if(istype(MT))
				engine_types += MT
		chosen_type = pick(engine_types)
	to_world_log("Chose Engine Map: [chosen_type.name]")
	admin_notice("<span class='danger'>Chose Engine Map: [chosen_type.name]</span>", R_DEBUG)

	// Annihilate movable atoms
	engine_loader.annihilate_bounds()
	CHECK_TICK
	// Actually load it
	chosen_type.load(T)

/datum/controller/subsystem/mapping/stat_entry(msg)
	if (!Debug2)
		return // Only show up in stat panel if debugging is enabled.
	. = ..()

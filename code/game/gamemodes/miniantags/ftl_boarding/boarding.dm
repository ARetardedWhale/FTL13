/datum/round_event/ghost_role/boarding
	minimum_required = 1 //tweaking
	var/max_allowed = 4 //tweaking
	role_name = "defender team"
	var/list/mob/dead/observer/candidates = list() //calling so we can decide is event is set or not
	var/list/mob/carbon/human/defenders_list = list()
	var/victorious = null

/datum/round_event/ghost_role/boarding/New()
	return

/datum/round_event/ghost_role/boarding/proc/check_role()
	candidates = get_candidates("defenders", null, ROLE_OPERATIVE)
	if(candidates.len < minimum_required)
		message_admins("No roles for boarding nerd")
		return 0
	else
		return 1

/datum/round_event/ghost_role/boarding/proc/event_setup()
	var/tc = 20 //TODO: sane number
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "defender_spawn")
			spawn_locs += get_turf(L)
	if(!spawn_locs.len)
		message_admins("NO SPAWN MARKS")
		return MAP_ERROR
	for(var/i in 1 to candidates.len)
		if(i > max_allowed) //TODO: change it to ship variable
			break
		var/mob/living/carbon/human/defender = new(pick(spawn_locs))
		var/datum/preferences/A = new
		var/mob/dead/selected = candidates[i]
		A.copy_to(defender)
		defender.dna.update_dna_identity()
		manageOutfit(defender,i,tc)
		var/datum/mind/Mind = new /datum/mind(selected.key)
		Mind.assigned_role = "Defender"
		Mind.special_role = "Defender"
		ticker.mode.traitors |= Mind
		Mind.active = 1

		if(spawnTerminal())
			var/datum/objective/nuclear/D = new() //TODO:objectives
			D.owner = Mind
			Mind.objectives += D

		Mind.transfer_to(defender)

		message_admins("[defender.key] has been made into defender by an event.")
		log_game("[defender.key] was spawned as a defender by an event.")
		spawned_mobs += defender

/datum/round_event/ghost_role/boarding/proc/victory()
	for(var/mob/living/carbon/human/loser in spawned_mobs)
		loser.gib()	//TODO:text
		message_admins("[loser.key] gibbed by an event defeat conditions.")
	victorious = TRUE
	qdel(src)

/datum/round_event/ghost_role/boarding/proc/defeat(var/zlevel)
	if(victorious)
		return 0
	for(var/obj/docking_port/stationary/D in SSstarmap.current_planet.docks)
		if(D.z != zlevel)
			continue
		qdel(D)
	SSstarmap.jump_port(SSstarmap.current_planet.main_dock)
	for(var/mob/living/carbon/human/winner in spawned_mobs)
		winner.gib()	//TODO:text
	qdel(src)
	return 1

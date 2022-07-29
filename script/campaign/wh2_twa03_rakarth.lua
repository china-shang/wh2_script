RakarthBeastHunts = {
	rakarth_faction_key = "wh2_twa03_def_rakarth",
	underway_cultures = {["wh_main_grn_greenskins"] = true,["wh_main_dwf_dwarfs"] = true,["wh2_main_skv_skaven"] = true},
	cultures_to_occupation_decisions = {
		["high_elves"] = {["1887827023"] = true, ["1714378711"] = true, ["2106190450"] = true, ["402144810"] = true},
		["greenskins"] = {["1479947113"] = true, ["212235124"] = true, ["967770119"] = true, ["1641379236"] = true, ["1796455264"] = true, ["1162295768"] = true, ["1177906742"] = true, ["988062801"] = true},
		["norscans"] = {["1697122960"] = true, ["1494482046"] = true, ["414759734"] = true, ["807179108"] = true},
		["lizardmen"] = {["1201212765"] = true, ["605364926"] = true, ["594609374"] = true, ["421401530"] = true},
	},
	rakarth_skill_key = "wh2_twa03_skill_def_rakarth_harpyclaw_bolts",
	
	----variables
	rakarth_skill_bonus_chance = 15, -- additive modifier applied to all rolls when Rakarth has the skil named above
	bad_luck_modifier_increment = 10,-- bad luck modifier for a specific incident goes up by this value every time an incident is not generated
	bad_luck_modifiers = {["raiding"] = 100, ["settlement_occupation"] = 100 , ["post_battle"] = 100}, --- these are set to 100 so the first time you do each in a campaign it's a guaranteed succss
	bad_luck_modifier_max = 30, --- bad luck modifier cannot exceed this value
	bad_luck_modifier_min = -100, --- bad luck modifier cannot go below this value
	bad_luck_modifier_soft_min = 0, --- bad luck modifier will correct to this value at start of turn if below this
	streak_prevention_value = -75, --- amount the bad luck modifier for a specific incident type goes down to following a successful roll
	chaos_corruption_threshold = 0.2, --- minimum chaos corruption in region to grant chaos bonus rolls
	display_debug = false,
	beast_incidents_for_rite = 5,
	province_capital_modifier = 10, -- for settlement occupation events, apply this bonus to roll if province capital

	rakarth_incidents =
	{
		["raiding"] = {
			["climate_mountain"] =
				{
					{"wh2_twa03_incident_rakarth_raid_hydra", 15},
					{"wh2_twa03_incident_rakarth_raid_harpies", 60},
				},
			["climate_temperate"] =
				{
					{"wh2_twa03_incident_rakarth_raid_wolves", 60},
				},
			["climate_island"] =
				{
					{"wh2_twa03_incident_rakarth_raid_wolves", 60},
				},
			["climate_frozen"] =
				{
					{"wh2_twa03_incident_rakarth_raid_wolves", 60},
				},
			["climate_desert"] =
				{
					{"wh2_twa03_incident_rakarth_raid_cold_ones", 60},
				},
			["climate_jungle"] =
				{
					{"wh2_twa03_incident_rakarth_raid_stegadon", 15},
					{"wh2_twa03_incident_rakarth_raid_cold_ones", 60}
				},
			["climate_savannah"] =
				{
					{"wh2_twa03_incident_rakarth_raid_cold_ones", 60},
				},
			["climate_wasteland"] =
				{
					{"wh2_twa03_incident_rakarth_raid_wolves", 60},
				},
			["climate_chaotic"] =
				{
					{"wh2_twa03_incident_rakarth_raid_manticore", 50},
				},
			["chaos_corrupted"] =
				{
					{"wh2_twa03_incident_rakarth_raid_manticore", 30},
				},
		},
		["settlement_occupation"] = {
			["high_elves"] =
				{
					{"wh2_twa03_incident_rakarth_settlement_high_elf_dragon", 5}
				},
			["greenskins"] =
				{
					{"wh2_twa03_incident_rakarth_settlement_greenskins_squigs", 60},
					{"wh2_twa03_incident_rakarth_settlement_greenskins_wolves",70}
				},
			["lizardmen"] =
				{
					{"wh2_twa03_incident_rakarth_settlement_lizardmen_carnosaur", 10},
					{"wh2_twa03_incident_rakarth_settlement_lizardmen_stegadon", 30},
					{"wh2_twa03_incident_rakarth_settlement_lizardmen_cold_ones", 80},
				},
			["norscans"] =
				{
					{"wh2_twa03_incident_rakarth_settlement_norsca_mammoth", 20},
					{"wh2_twa03_incident_rakarth_settlement_norsca_wolves", 70}
				},
		},
		["post_battle"] = {
			["naval"] =
				{
					{"wh2_twa03_incident_rakarth_battle_kharybdiss", 20, "TW_WH2_DLC10_QUEEN_CRONE"},
					{"wh2_twa03_incident_rakarth_battle_harpies", 40},
				},
			["underway"] =
				{
					{"wh2_twa03_incident_rakarth_battle_squigs", 40},
				},
			["land"] =
				{
					{"wh2_twa03_incident_rakarth_battle_harpies", 40},
				},
		},
	},

	ai_units ={
		---key, starting amount, replen chance, max in pool
		{"wh2_main_def_mon_black_dragon", 0, 1, 1},
		{"wh2_main_lzd_cav_cold_ones_feral_0", 2, 15, 3},
		{"wh2_twa03_def_mon_wolves_0", 2, 15, 3},
		{"wh2_main_lzd_mon_stegadon_0", 0, 3, 2},
		{"wh2_main_def_inf_harpies", 2, 15, 5},
		{"wh2_dlc14_def_mon_bloodwrack_medusa_0", 0, 2, 1},
		{"wh2_main_lzd_mon_carnosaur_0", 0, 2, 1},
		{"wh2_dlc10_def_mon_feral_manticore_0", 0, 5, 2},
		{"wh2_dlc10_def_mon_kharibdyss_0", 0, 2, 1},
		{"wh2_twa03_def_mon_war_mammoth_0", 0, 2, 1},
		{"wh2_main_def_mon_war_hydra", 0, 3, 1},
		{"wh_twa03_def_inf_squig_explosive_0", 0, 10, 2},
	},

	incident_count = 0
}
-----------------
----FUNCTIONS----
-----------------

--LISTENER SETUP--

function RakarthBeastHunts:setup_rakarth_listeners()

	local rakarth_interface =  cm:get_faction(self.rakarth_faction_key)
	if rakarth_interface ~= false then 
		if rakarth_interface:is_human() then
			self:setup_settlement_occupation_listener()
			self:setup_post_battle_listener()
			self:setup_raiding_listener()
			self:setup_quest_chain_completion_listener()

			cm:add_faction_turn_start_listener_by_name(
				"rakarth_monster_pen_update",
				"wh2_twa03_def_rakarth",
				function()
					for k, v in pairs(self.bad_luck_modifiers) do
						if self.display_debug then
							out.design("Rakarth is starting his turn with a bad luck modifier of "..tostring(v).." in category "..k)
						end
						if v < self.bad_luck_modifier_soft_min then
							if self.display_debug then
								out.design("This is below "..self.bad_luck_modifier_soft_min.." so resetting to "..self.bad_luck_modifier_soft_min)
							end
							self.bad_luck_modifiers[k] = self.bad_luck_modifier_soft_min
						end
					end
				end,
				true)

		elseif cm:is_new_game() then
			self:setup_ai_merc_pool()
		end
	end
end

function RakarthBeastHunts:setup_quest_chain_completion_listener()
	core:add_listener(
		"Rakarth_QuestChainCompleted",
		"MissionSucceeded",
		function(context)
			return context:mission():mission_record_key():find("whip_of_agony_stage_2")
		end,
		function(context)
			--Grant Black Ark reward to pool
			cm:spawn_character_to_pool(self.rakarth_faction_key, "names_name_1602715018", "", "names_name_1270751732", "", 18, true, "general", "wh2_main_def_black_ark", false, "wh2_main_art_set_def_black_ark");
		end,
		true
	);
end

function RakarthBeastHunts:setup_settlement_occupation_listener()
	core:add_listener(
		"RakarthFactionCharacterPerformsSettlementOccupationDecision",
		"CharacterPerformsSettlementOccupationDecision",
		function(context)
			return self:is_char_rakarth_general_with_army(context:character())
		end,
		function(context)
			local event_type = "settlement_occupation"
			local occupation_decision = context:occupation_decision()
			local garrison_residence = context:garrison_residence()
			local occupied_subculture = false
			local modifiers = self.bad_luck_modifiers[event_type]
			local character_rank = context:character():rank()

			modifiers = modifiers + character_rank

			if context:character():has_skill(RakarthBeastHunts.rakarth_skill_key) then
				modifiers = modifiers + RakarthBeastHunts.rakarth_skill_bonus_chance
			end

			if RakarthBeastHunts:is_occupied_residence_province_capital(garrison_residence) then
				modifiers = modifiers + RakarthBeastHunts.province_capital_modifier
			end

			for k,v in pairs(self.cultures_to_occupation_decisions) do
				if v[occupation_decision] then
					occupied_subculture = k
				end
			end

			if occupied_subculture == false then
				return false
			end

			if self.display_debug then
				out.design("Rakarth has occupied a settlement belonging to "..occupied_subculture)
			end

			self:generate_beast_incident(event_type, occupied_subculture, modifiers, context:character():command_queue_index())

		end,
		true
	);
end

function RakarthBeastHunts:setup_post_battle_listener()
	core:add_listener(
		"RakarthFactionCharacterCompletedBattle",
		"CharacterCompletedBattle",
		function(context)
			if not context:pending_battle():has_contested_garrison() and self:is_char_rakarth_general_with_army(context:character()) and self:rakarth_faction_won_battle(context:pending_battle()) then
				return true
			end
		end,
		function(context)
			local pending_battle = context:pending_battle()
			local character = context:character()
			local casualty_coefficient = self:get_casualty_coefficient(pending_battle)
			local event_type = "post_battle"
			local beast_incident_generated = false
			local battle_type = "land"
			local character_rank = context:character():rank()

			local modifiers = self.bad_luck_modifiers[event_type] + (casualty_coefficient*50)
			modifiers = modifiers + character_rank
			if character:has_skill(RakarthBeastHunts.rakarth_skill_key) then
				modifiers = modifiers + RakarthBeastHunts.rakarth_skill_bonus_chance
			end

		
			if self:is_character_at_sea(character) then
				battle_type = "naval"
			elseif self:is_underway_battle(pending_battle) then
				battle_type = "underway"
			end
			beast_incident_generated = self:generate_beast_incident(event_type, battle_type, modifiers, character:command_queue_index())
		

			---if you didn't get a beast from the first roll, give a bonus roll if you choose to slaughter.
			if not beast_incident_generated then
				if self.display_debug then
					out.design("Beast incident failed, setting up slaughter listener")
				end
				RakarthBeastHunts:setup_slaughter_listener(battle_type)
			end

		end,
		true
	);
end

function RakarthBeastHunts:setup_raiding_listener()
	core:add_listener(
		"RakarthFactionCharacterTurnStart",
		"CharacterTurnStart",
		function(context)
			local character = context:character()
			return self:is_char_rakarth_general_with_army(character) and self:character_is_raiding(character)
		end,
		function(context)
			local character = context:character()
			local climate_key = self:get_local_climate_from_character(character)
			local chaos_corruption = self:get_local_chaos_corruption_from_character(character)
			local event_type = "raiding"
			local beast_incident_generated = false
			local modifiers = self.bad_luck_modifiers[event_type]
			local character_rank = context:character():rank()

			modifiers = modifiers + character_rank

			if character:has_skill(RakarthBeastHunts.rakarth_skill_key) then
				modifiers = modifiers + RakarthBeastHunts.rakarth_skill_bonus_chance
			end

			if self:is_relevant_climate(climate_key) then
				beast_incident_generated = self:generate_beast_incident(event_type, climate_key, modifiers, character:command_queue_index())
			end

			if beast_incident_generated == false and chaos_corruption> self.chaos_corruption_threshold then
				self:generate_beast_incident(event_type, "chaos_corrupted", modifiers + (chaos_corruption*50), character:command_queue_index())
			end

		end,
		true
	);
end

function RakarthBeastHunts:setup_slaughter_listener(battle_type)
	core:add_listener(
		"RakarthFactionCharacterPostBattleSlaughter",
		"CharacterPostBattleSlaughter",
		true,
		function(context)
			local event_type = "post_battle"
			self:generate_beast_incident(event_type, battle_type, self.bad_luck_modifiers[event_type], context:character():command_queue_index())
			core:remove_listener("RakarthFactionCharacterPostBattleEnslave")
			core:remove_listener("RakarthFactionCharacterPostBattleRelease")
		end,
		false
	);

	--we also need to set up listeners for the other choices so that we can remove the slaughter one if it's not chosen
	core:add_listener(
		"RakarthFactionCharacterPostBattleEnslave",
		"CharacterPostBattleEnslave",
		true,
		function()
			core:remove_listener("RakarthFactionCharacterPostBattleSlaughter")
			core:remove_listener("RakarthFactionCharacterPostBattleRelease")
		end,
		false
	);

	core:add_listener(
		"RakarthFactionCharacterPostBattleRelease",
		"CharacterPostBattleRelease",
		true,
		function()
			core:remove_listener("RakarthFactionCharacterPostBattleEnslave")
			core:remove_listener("RakarthFactionCharacterPostBattleSlaughter")
		end,
		false
	);

end

---CORE FUNCTIONS

function RakarthBeastHunts:generate_beast_incident(event_type, event_context, chance_mod, acting_character_cqi)
	local beast_incident_pool = self.rakarth_incidents[event_type][event_context]
	local cqi_for_incident = 0

	if is_number(acting_character_cqi) then
		cqi_for_incident = acting_character_cqi
	end

	if self.display_debug then
		out.design("generate_beast_incident called with event_type: "..event_type.." and event_context "..event_context)
	end

	local base_roll = cm:random_number()
	local weighted_roll = base_roll+chance_mod
	local beast_incident_generated = false

	if self.display_debug then
		out.design("Base roll is "..tostring(base_roll))
		out.design("Bad luck modifier for this event_type is: "..tostring(self.bad_luck_modifiers[event_type]))
		out.design("Additional mod is "..tostring(chance_mod - self.bad_luck_modifiers[event_type]))
		out.design("Total weighting: "..tostring(chance_mod))
		out.design("Weighted roll is "..tostring(weighted_roll))
	end

	for i, v in pairs(beast_incident_pool) do
		if v[3] == nil or cm:is_multiplayer() or cm:is_dlc_flag_enabled(v[3]) then
			local threshold = 100 - v[2]

			if self.display_debug then
				out.design("Rolling for incident "..v[1].." with threshold "..tostring(threshold))
			end

			if weighted_roll > threshold then
				if self.display_debug then
					out.design("Weighted roll exceeds required threshold")
				end
				self.incident_count = self.incident_count + 1
				core:trigger_event("ScriptEventRakarthBeastIncidentGenerated",v[1])

				local rakarth_faction_cqi = cm:get_faction(self.rakarth_faction_key):command_queue_index()
				cm:trigger_incident_with_targets(rakarth_faction_cqi, v[1],0,0,cqi_for_incident,0,0,0)
				beast_incident_generated = true
				break
			end
		end
	end

	if not beast_incident_generated then
		if self.bad_luck_modifiers[event_type] < self.bad_luck_modifier_max then
			self.bad_luck_modifiers[event_type] = self.bad_luck_modifiers[event_type] + self.bad_luck_modifier_increment
		else
			self.bad_luck_modifiers[event_type] = self.bad_luck_modifier_max
		end

		if self.display_debug then
			out.design("No incident generated, increasing bad luck modifier for "..event_type.."to "..tostring(self.bad_luck_modifiers[event_type]))
		end
	else
		if self.bad_luck_modifiers[event_type] >= self.bad_luck_modifier_min then
			if self.bad_luck_modifiers[event_type] > self.bad_luck_modifier_max then 
				self.bad_luck_modifiers[event_type] = self.bad_luck_modifier_max
			end
			self.bad_luck_modifiers[event_type] = self.bad_luck_modifiers[event_type] + self.streak_prevention_value
		else
			self.bad_luck_modifiers[event_type] = self.bad_luck_modifier_min 
		end

		if self.display_debug then
			out.design("Incident generated, decreasing bad luck modifier for "..event_type.." to "..tostring(self.bad_luck_modifiers[event_type]))
		end
	end

	return beast_incident_generated
end

--- for the AI, we simply overwrite the merc pool setup with one that fills up automatically via code

function RakarthBeastHunts:setup_ai_merc_pool()
	local rakarth_interface = cm:get_faction(self.rakarth_faction_key)

	for i,v in pairs(self.ai_units) do
		cm:add_unit_to_faction_mercenary_pool(
			rakarth_interface,
			v[1], -- key
			v[2], -- count
			v[3], --replen chance
			v[4], -- max units
			1, -- max per turn
			0, -- xp
			"",
			"",
			"",
			false
		)
	end	
end

--- QUERY FUNCTIONS

function RakarthBeastHunts:is_char_rakarth_general_with_army(character)
	if character:is_null_interface() then
		script_error("Function RakarthBeastHunts:is_char_rakarth_general_with_army() called without valid character interface")
		return false
	elseif not cm:char_is_mobile_general_with_army(character) then
		return false
	else 
		return character:faction():name() == self.rakarth_faction_key
	end
end

function RakarthBeastHunts:get_local_climate_from_character(character)

	local region_interface

	if character:is_null_interface() then
		script_error("Function RakarthBeastHunts:get_local_climate_from_character() called without valid character interface")
		return false
	elseif not character:has_region() then
		script_error("Function RakarthBeastHunts:get_local_climate_from_character() called for a character without a region")
		return false
	else 
		region_interface = character:region()
	end

	local settlement = region_interface:settlement()

	if not settlement:is_null_interface() then
		return settlement:get_climate()
	else 
		return false
	end
end

function RakarthBeastHunts:is_relevant_climate(climate_key)
	if climate_key == false then
		return false
	elseif not is_string(climate_key) then
		script_error("Function RakarthBeastHunts:is_relevant_climate() is trying to pass a climate key that is not false or a string")
		return false
	end

	local relevant_climates_table = self.rakarth_incidents["raiding"]

	if relevant_climates_table[climate_key] == nil then 
		return false
	else
		return true
	end
end

function RakarthBeastHunts:get_local_chaos_corruption_from_character(character)

	if character:is_null_interface() then
		script_error("Function RakarthBeastHunts:get_local_chaos_corruption() called without valid character interface")
		return false
	elseif not character:has_region() then
		script_error("Function RakarthBeastHunts:get_local_chaos_corruption() called for a character without a region")
		return false
	else 
		return character:region():religion_proportion("wh_main_religion_chaos")
	end

end

function RakarthBeastHunts:is_underway_battle(pending_battle)
	if pending_battle:is_null_interface() then
		script_error("Function RakarthBeastHunts:is_underway_battle() called without valid pending battle interface")
		return false
	end

	if not cm:pending_battle_cache_faction_is_attacker(self.rakarth_faction_key) then
		return false
	end

	local num_defenders = cm:pending_battle_cache_num_defenders()

	for i =1, num_defenders do
		local char_cqi, mf_cqi, faction_name = cm:pending_battle_cache_get_defender(i)
		local force_interface = cm:get_military_force_by_cqi(mf_cqi)
		if force_interface:active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_TUNNELING" then
			local defender_culture = cm:get_faction(faction_name):culture()
			if self.underway_cultures[defender_culture] then
				return true
			end
		end
	end


	return false
end

function RakarthBeastHunts:is_character_at_sea(character)
	if character:is_null_interface() then
		script_error("Function RakarthBeastHunts:is_character_at_sea() called without valid character")
		return false
	else
		return character:is_at_sea()
	end
end

function RakarthBeastHunts:get_casualty_coefficient(pending_battle)
	if pending_battle:is_null_interface() then
		script_error("Function RakarthBeastHunts:get_casualty_coefficient() called without valid pending battle interrface")
		return false
	end
	local attacker_value = cm:pending_battle_cache_attacker_value();
	local defender_value = cm:pending_battle_cache_defender_value();

	local overall_value = attacker_value + defender_value

	local attacker_ratio = attacker_value/overall_value
	local defender_ratio = 1 - attacker_ratio

	local defender_casualties = pending_battle:percentage_of_defender_killed();
	local attacker_casualties = pending_battle:percentage_of_attacker_killed();

	local weighted_attacker_casualties = attacker_ratio*attacker_casualties
	local weighted_defender_casualties = defender_ratio*defender_casualties

	local total_casualties = weighted_attacker_casualties + weighted_defender_casualties

	return  tonumber(string.format("%." .. 2 .. "f", total_casualties))
end

function RakarthBeastHunts:is_occupied_residence_province_capital(garrison_residence)
	local settlement = garrison_residence:settlement_interface()
	if settlement:is_null_interface() then
		script_error("Function RakarthBeastHunts:is_occupied_residence_province_capital() called without valid settlement")
		return false
	end
	return settlement:region():is_province_capital()

end

function RakarthBeastHunts:character_is_raiding(character)
	if character:is_null_interface() then
		script_error("Function RakarthBeastHunts:character_is_raiding() called without valid character")
		return false

	elseif not character:has_military_force() then
		return false

	elseif character:military_force():active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_LAND_RAID" then
		return true

	else 
		return false

	end
end

function RakarthBeastHunts:rakarth_faction_won_battle(pending_battle)
	if pending_battle:is_null_interface() then
		script_error("Function RakarthBeastHunts:rakarth_faction_won_land_battle() called without valid pending battle interrface")
		return false
	end

	local winner_faction_key = ""

	if pending_battle:has_attacker() then
		local attacker_faction_key = pending_battle:attacker():faction():name()
		if pending_battle:attacker():won_battle() then
			winner_faction_key = attacker_faction_key
		end
	end

	if pending_battle:has_defender() then
		local defender_faction_key = pending_battle:defender():faction():name()
		if pending_battle:defender():won_battle() then
			winner_faction_key = defender_faction_key
		end
	end

	if winner_faction_key == self.rakarth_faction_key then
		return true
	else
		return false
	end
end

----save/load

cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("RakarthBadLuckModifiers", RakarthBeastHunts.bad_luck_modifiers, context)
		cm:save_named_value("RakarthIncidentCount", RakarthBeastHunts.incident_count, context)
	end
);
cm:add_loading_game_callback(
	function(context)
		if not cm:is_new_game() then
			RakarthBeastHunts.bad_luck_modifiers = cm:load_named_value("RakarthBadLuckModifiers", RakarthBeastHunts.bad_luck_modifiers, context)
			RakarthBeastHunts.incident_count = cm:load_named_value("RakarthIncidentCount", RakarthBeastHunts.incident_count, context)
		end
	end
)
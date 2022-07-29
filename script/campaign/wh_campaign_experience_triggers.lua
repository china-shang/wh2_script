-- amount of experience to give for battle results
xp_battle_defeat_crushing						= 200;
xp_battle_defeat								= 400;
xp_battle_defeat_valiant						= 600;
xp_battle_victory_pyrrhic						= 600;
xp_battle_victory								= 1000;
xp_battle_victory_heroic						= 1400;
xp_battle_victory_ambush						= 400;	-- this is added on top of the above values if the battle was an ambush
xp_battle_modifier_hero							= 1;	-- this is the modifier to the above values when the participating character is a Hero
xp_battle_modifier_secondary_general			= 0.5;	-- this is the modifier to the above values when the participating character is a reinforcing Lord


-- amount of experience to give Lords
xp_general_is_garrisoned 						= 100;
xp_general_is_raiding 							= 200;
xp_general_completes_horde_building 			= 200;
xp_general_occupies_settlement					= 200;
xp_general_razes_settlement						= 200;

-- amount of experience to give AI lords
xp_ai_general_easy                              = 0;
xp_ai_general_normal                            = 50;
xp_ai_general_hard                              = 75;
xp_ai_general_very_hard                         = 100;
xp_ai_general_legendary                         = 125;

-- amount of experience to give Heroes
xp_hero_is_active	 							= 100;
xp_hero_is_embedded 							= 50;

xp_hero_target_settlement_fail_critical			= 200;
xp_hero_target_settlement_fail					= 400;
xp_hero_target_settlement_fail_opportune		= 600;
xp_hero_target_settlement_success				= 1200;

xp_hero_target_army_fail_critical				= 200;
xp_hero_target_army_fail						= 400;
xp_hero_target_army_fail_opportune				= 600;
xp_hero_target_army_success						= 1200;

xp_hero_target_character_fail_critical			= 200;
xp_hero_target_character_fail					= 400;
xp_hero_target_character_fail_opportune			= 600;
xp_hero_target_character_success				= 1000;
xp_hero_target_character_success_critical		= 1600;
xp_hero_target_character_success_bonus_10		= 300;	-- this is added if the assassination target is > rank 10
xp_hero_target_character_success_bonus_20		= 600;	-- this is added if the assassination target is > rank 20
xp_hero_target_character_success_bonus_30		= 800;	-- this is added if the assassination target is > rank 30

xp_ritual_of_hoeth								= 200; -- this is given per turn to Loremasters, Archmages and Mages per turn while the ritual is active
xp_ritual_of_hekarti							= 200; -- this is given per turn to Sorceresses and Supreme Sorceresses per turn while the ritual is active
xp_ritual_of_eldrazor							= 200; -- this is given per turn to Lords and Nobles per turn while the ritual is active

local m_xp_disabled_characters = {
	"names_name_535773478" -- Azrik the Maze Keeper (ME)
}

function start_character_turn_start_experience_monitor()
	core:add_listener(
		"CharacterTurnStart_experience",
		"CharacterTurnStart",
		true,
		function(context)
			local character = context:character();
		
			if cm:char_is_general(character) then
				-- character is a general
				local difficulty = character:model():combined_difficulty_level()

				if not character:faction():is_human() then
					if difficulty == 1 then
						add_experience(context, true, xp_ai_general_easy);
					elseif difficulty == 0 then
						add_experience(context, true, xp_ai_general_normal);
					elseif difficulty == -1 then
						add_experience(context, true, xp_ai_general_hard);
					elseif difficulty == -2 then
						add_experience(context, true, xp_ai_general_very_hard);
					elseif difficulty == -3 then
						add_experience(context, true, xp_ai_general_legendary);
					end
				end

				if character:has_garrison_residence() then
					-- general is garrisoned
					add_experience(context, true, xp_general_is_garrisoned);
				end;
				
				-- general is raiding
				if character:has_military_force() then
					local mf = character:military_force();
					
					if mf:active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_LAND_RAID" or mf:active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_SET_CAMP_RAIDING" then
						add_experience(context, true, xp_general_is_raiding);
					end;
				end;

				--ritual of eldrazor is active
				if character_has_ritual_of_eldrazor(character) and character:has_military_force() then
					add_experience(context, true, xp_ritual_of_eldrazor, true);
				end;
				-- ritual of hoeth (mage/loremaster)
				if character_has_ritual_of_hoeth(character) and character_is_mage(character) and character:has_military_force() then
					add_experience(context, true, xp_ritual_of_hoeth, true);
				end;

				if character_has_ritual_of_hekarti(character) and character:has_military_force() then
					add_experience(context, true, xp_ritual_of_hekarti, true);
				end;
			
			else
				-- character is an agent/hero

				-- agent is active
				if not character:is_wounded() then
					add_experience(context, false, xp_hero_is_active);
				end;
				
				-- agent is embedded
				if character:is_embedded_in_military_force() then
					add_experience(context, false, xp_hero_is_embedded);
				end;
				
				-- ritual of hoeth (mage/loremaster)
				if character_has_ritual_of_hoeth(character) and character_is_mage(character) then
					add_experience(context, false, xp_ritual_of_hoeth, true);
				end;

				--- ritual of eldrazor (lords, nobles)
				if character_has_ritual_of_eldrazor(character) then
					add_experience(context, false, xp_ritual_of_eldrazor, true);
				end;
				
				-- ritual of hekarti (sorceress)
				if character_has_ritual_of_hekarti(character) then
					add_experience(context, false, xp_ritual_of_hekarti, true);
				end;
			end;
		end,
		true
	);
end;


function setup_experience_triggers()

	-- only start the experience triggers once a faction has started turn two
	if cm:model():turn_number() > 1 then
		start_character_turn_start_experience_monitor();
	else
		core:add_listener(
			"Pre_CharacterTurnStart_experience",
			"FactionTurnStart",
			function() return cm:model():turn_number() > 1 end,
			start_character_turn_start_experience_monitor,
			false
		);
	end;
	
	core:add_listener(
		"GarrisonOccupiedEvent_experience",
		"GarrisonOccupiedEvent",
		true,
		function(context)
			-- general captures and occupies a settlement
			add_experience(context, true, xp_general_occupies_settlement);
		end,
		true
	);
	
	core:add_listener(
		"CharacterRazedSettlement_experience",
		"CharacterRazedSettlement",
		true,
		function(context)
			-- general captures and razes a settlement
			add_experience(context, true, xp_general_razes_settlement);
		end,
		true
	);
	
	core:add_listener(
		"MilitaryForceBuildingCompleteEvent_experience",
		"MilitaryForceBuildingCompleteEvent",
		true,
		function(context)
			-- horde general constructs a building
			add_experience(context, true, xp_general_completes_horde_building);
		end,
		true
	);
	
	core:add_listener(
		"CharacterGarrisonTargetAction_experience",
		"CharacterGarrisonTargetAction",
		true,
		function(context)
			-- agent targets a settlement
			-- ignore if an agent is scouting ruins
			if context:agent_action_key():find("scout_settlement") and context:garrison_residence():faction():culture() ~= "wh2_main_skv_skaven" then
				return;
			end;
			
			local value = xp_hero_target_settlement_success;
			
			if context:mission_result_critial_failure() then
				value = xp_hero_target_settlement_fail_critical;
			elseif context:mission_result_failure() then
				value = xp_hero_target_settlement_fail;
			elseif context:mission_result_opportune_failure() then
				value = xp_hero_target_settlement_fail_opportune;
			end;
			
			add_experience(context, false, value);
		end,
		true
	);
	
	core:add_listener(
		"CharacterCharacterTargetAction_experience",
		"CharacterCharacterTargetAction",
		true,
		function(context)
			local ability = context:ability();
			
			-- agent targets an army
			if ability == "hinder_army" then
				local value = xp_hero_target_army_success;
				
				if context:mission_result_critial_failure() then
					value = xp_hero_target_army_fail_critical;
				elseif context:mission_result_failure() then
					value = xp_hero_target_army_fail;
				elseif context:mission_result_opportune_failure() then
					value = xp_hero_target_army_fail_opportune;
				end;
				
				add_experience(context, false, value);
				
			-- agent targets a character (assassination)
			elseif ability == "hinder_character" or ability == "hinder_agent" then
				local value = xp_hero_target_character_fail;
				local target_rank = context:target_character():rank();
				
				if context:mission_result_critial_failure() then
					value = xp_hero_target_character_fail_critical;
				elseif context:mission_result_opportune_failure() then
					value = xp_hero_target_character_fail_opportune;
				elseif context:mission_result_critial_success() then
					value = xp_hero_target_character_success_critical + add_assassination_bonus(target_rank);
				elseif context:mission_result_success() then
					value = xp_hero_target_character_success + add_assassination_bonus(target_rank);
				end;
				
				add_experience(context, false, value);
			end;
		end,
		true
	);
	
	core:add_listener(
		"CharacterCompletedBattle_experience",
		"CharacterCompletedBattle",
		true,
		function(context)
			-- general completes a battle
			calculate_battle_result_experience(context, true, false);
		end,
		true
	);
	
	core:add_listener(
		"HeroCharacterParticipatedInBattle_experience",
		"HeroCharacterParticipatedInBattle",
		true,
		function(context)
			-- embedded agent completes a battle
			calculate_battle_result_experience(context, false, false);
		end,
		true
	);
	
	core:add_listener(
		"CharacterParticipatedAsSecondaryGeneralInBattle_experience",
		"CharacterParticipatedAsSecondaryGeneralInBattle",
		true,
		function(context)
			-- reinforcing general completes a battle
			calculate_battle_result_experience(context, true, true);
		end,
		true
	);
end;

function add_assassination_bonus(target_rank)
	if target_rank > 30 then
		return xp_hero_target_character_success_bonus_30;
	elseif target_rank > 20 then
		return xp_hero_target_character_success_bonus_20;
	elseif target_rank > 10 then
		return xp_hero_target_character_success_bonus_10;
	else
		return 0;
	end;
end;

function calculate_battle_result_experience(context, is_general, is_secondary_general)
	local value = 0;
	
	local pb = cm:model():pending_battle();
	local attacker_battle_result = pb:attacker_battle_result();
	local defender_battle_result = pb:defender_battle_result();
	
	if context:character():won_battle() then
		if attacker_battle_result == "pyrrhic_victory" or defender_battle_result == "pyrrhic_victory" then
			value = xp_battle_victory_pyrrhic;
		elseif attacker_battle_result == "heroic_victory" or defender_battle_result == "heroic_victory" then
			value = xp_battle_victory_heroic;
		else
			value = xp_battle_victory;
		end;
		
		-- add the ambush bonus if it's an ambush battle
		if is_general and pb:attacker() == context:character() and pb:ambush_battle() then
			value = value + xp_battle_victory_ambush;
		end;
	-- don't award losing XP if it's a quest battle
	elseif not battle_is_quest_battle(pb) then
		if attacker_battle_result == "crushing_defeat" or defender_battle_result == "crushing_defeat" then
			value = xp_battle_defeat_crushing;
		elseif attacker_battle_result == "valiant_defeat" or defender_battle_result == "valiant_defeat" then
			value = xp_battle_defeat_valiant;
		else
			value = xp_battle_defeat;
		end;
	end;
	
	if not is_general then
		value = value * xp_battle_modifier_hero;
	elseif is_secondary_general then
		value = value * xp_battle_modifier_secondary_general;
	end;	
	
	add_experience(context, is_general, value);
end;

function battle_is_quest_battle(pb)
	if (pb:has_attacker() and pb:attacker():faction():is_quest_battle_faction()) or (pb:has_defender() and pb:defender():faction():is_quest_battle_faction()) then
		return true;
	else
		return false;
	end;
end;

local function character_can_gain_xp(character)
	local character_forename = character:get_forename()

	for k, v in ipairs(m_xp_disabled_characters) do
		if(v == character_forename) then
			return false
		end
	end

	return true
end

function add_experience(context, is_general, value, ignore_rituals)
	------ special rules ------
	
	local character = context:character();
	local can_gain_xp = character_can_gain_xp(character)


	if(can_gain_xp) then
		local faction = character:faction();
		local character_subtype = character:character_subtype_key();
		
		-- don't give XP if it's a black ark or a hero from a rite
		if character_subtype == "wh2_main_skv_plague_priest_ritual" or character_subtype == "wh2_main_skv_warlock_engineer_ritual" or character_subtype == "wh2_dlc09_tmb_necrotect_ritual" then
			return;
		end;
		
		-- human Skarsnik receives 2x experience (1x for generals if Karak Eight Peaks is not owned)
		if faction:is_human() and faction:name() == "wh_main_grn_crooked_moon" and (skarsnik_has_karak() or not is_general) then
			value = value * 2;
		end;
		
		-- characters in Lileath's Blessing stance get 1.2x experience
		if character_in_lileaths_blessing(character) and character_is_mage(character) then
			value = value * 1.2;
		end;
		
		-- ritual bonuses
		if not ignore_rituals then
			-- Loremasters/Mages whose faction have the Ritual of Hoeth get 1.5x experience
			if character_has_ritual_of_hoeth(character) and character_is_mage(character) then
				value = value * 1.5;
			end;
			
			-- Sorceresses whose faction have the Ritual of Hekarti get 1.5x experience
			if character_has_ritual_of_hekarti(character) then
				value = value * 1.5;
			end;

			---Lords and Princes whose faction have the Ritual of Eldrazor get 1.5x experience
			if character_has_ritual_of_eldrazor(character) then
				value = value * 1.5;
			end;

		end

		cm:get_game_interface():add_agent_experience(cm:char_lookup_str(character), value);
	end
end;

function skarsnik_has_karak()
	local region_karak = cm:get_region("wh_main_eastern_badlands_karak_eight_peaks");
	local crooked_moon = cm:get_faction("wh_main_grn_crooked_moon");

	if crooked_moon and region_karak and region_karak:owning_faction() == crooked_moon and region_karak:building_exists("wh_dlc06_grn_eight_peaks_3") then
		return true;
	else
		return false;
	end;
end;

function character_in_lileaths_blessing(character)
	if character:faction():culture() == "wh2_main_hef_high_elves" and (character:has_military_force() and character:military_force():active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_CHANNELING") or (character:is_embedded_in_military_force() and character:embedded_in_military_force():active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_CHANNELING") then
		return true;
	else
		return false;
	end;
end;

function character_has_ritual_of_hoeth(character)
	if character:faction():has_effect_bundle("wh2_main_ritual_hef_hoeth")then
		return true;
	else
		return false;
	end;
end;

function character_is_mage(character)
	if character:character_subtype("wh2_main_hef_loremaster_of_hoeth")
		or character:character_type("wizard")
		or string.match(character:character_subtype_key(), "wh2_dlc15_hef_archmage.*")
		or character:character_subtype("wh2_main_hef_teclis")
		or character:character_subtype("wh2_dlc15_hef_eltharion")
	then
		return true;
	else
		return false;
	end;
end;

function character_has_ritual_of_eldrazor(character)
	if character:faction():has_effect_bundle("wh2_dlc15_ritual_hef_eldrazor") and (character:character_type("general") or character:character_type("champion") ) then
		return true;
	else
		return false;
	end;
end;

function character_has_ritual_of_hekarti(character)
	if character:faction():has_effect_bundle("wh2_main_ritual_def_hekarti") and (character:character_type("wizard")	or string.match(character:character_subtype_key(), "wh2_dlc10_def_supreme_sorceress_.*")) 
	then
		return true;
	else
		return false;
	end;
end;

function disable_character_xp_gain(character_forename)
	-- This blocks about 95% of character xp gain. They can still get xp from events etc.
	for k, v in ipairs(m_xp_disabled_characters) do
		if(v == character_forename) then
			-- character already disabled
			return false
		end
	end

	table.insert(m_xp_disabled_characters, character_forename)
end

cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("disabled_character_xp_list", m_xp_disabled_characters, context);
	end
)

cm:add_loading_game_callback(
	function(context)
		m_xp_disabled_characters = cm:load_named_value("disabled_character_xp_list", m_xp_disabled_characters, context);
	end
)
local starting_vows = {
	{faction = "wh_main_brt_bretonnia", traits = {{key = "wh_dlc07_trait_brt_knights_vow_knowledge_pledge", points = 6}, {key = "wh_dlc07_trait_brt_questing_vow_campaign_pledge", points = 2}, {key = "wh_dlc07_trait_brt_grail_vow_untaint_pledge", points = 6}}},
	{faction = "wh_main_brt_bordeleaux", traits = {{key = "wh_dlc07_trait_brt_knights_vow_knowledge_pledge", points = 6}}},
	{faction = "wh2_dlc14_brt_chevaliers_de_lyonesse", traits = {{key = "wh_dlc07_trait_brt_knights_vow_knowledge_pledge", points = 6}, {key = "wh_dlc07_trait_brt_questing_vow_campaign_pledge", points = 2}}}

};	

local vow_to_troth = {
	["wh_dlc07_trait_brt_knights_vow_knowledge_pledge"] = "wh_dlc07_trait_brt_protection_troth_knowledge_pledge",
	["wh_dlc07_trait_brt_knights_vow_order_pledge"] = "wh_dlc07_trait_brt_protection_troth_order_pledge",
	["wh_dlc07_trait_brt_knights_vow_chivalry_pledge"] = "wh_dlc07_trait_brt_protection_troth_chivalry_pledge",
	["wh_dlc07_trait_brt_questing_vow_campaign_pledge"] = "wh_dlc07_trait_brt_wisdom_troth_campaign_pledge",
	["wh_dlc07_trait_brt_questing_vow_heroism_pledge"] = "wh_dlc07_trait_brt_wisdom_troth_heroism_pledge",
	["wh_dlc07_trait_brt_questing_vow_protect_pledge"] = "wh_dlc07_trait_brt_wisdom_troth_protect_pledge",
	["wh_dlc07_trait_brt_grail_vow_untaint_pledge"] = "wh_dlc07_trait_brt_virtue_troth_untaint_pledge",
	["wh_dlc07_trait_brt_grail_vow_valour_pledge"] = "wh_dlc07_trait_brt_virtue_troth_valour_pledge",
	["wh_dlc07_trait_brt_grail_vow_destroy_pledge"] = "wh_dlc07_trait_brt_virtue_troth_destroy_pledge"
};

local vow_max_points = {
	["wh_dlc07_trait_brt_questing_vow_campaign_pledge"] = 2,
	["wh_dlc07_trait_brt_questing_vow_heroism_pledge"] = 2,
	["wh_dlc07_trait_brt_questing_vow_protect_pledge"] = 2,
	["wh_dlc07_trait_brt_grail_vow_untaint_pledge"] = 2
};

local vow_lords = {
	-- Chaos
	["chs_archaon"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["chs_kholek_suneater"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["chs_prince_sigvald"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["chs_lord_of_change"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	-- Skaven
	["wh2_dlc09_skv_tretch_craventail"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["wh2_dlc12_skv_ikit_claw"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["wh2_dlc14_skv_deathmaster_snikch"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["wh2_main_skv_lord_skrolk"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["wh2_main_skv_queek_headtaker"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["wh2_dlc16_skv_throt_the_unclean"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	-- Vampire Counts
	["dlc04_vmp_helman_ghorst"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["dlc04_vmp_vlad_con_carstein"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["pro02_vmp_isabella_von_carstein"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["vmp_heinrich_kemmler"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["vmp_mannfred_von_carstein"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["wh_dlc05_vmp_red_duke"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	-- Vampire Coast
	["wh2_dlc11_cst_aranessa"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["wh2_dlc11_cst_cylostra"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["wh2_dlc11_cst_harkon"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	["wh2_dlc11_cst_noctilus"] = "wh_dlc07_trait_brt_grail_vow_untaint_pledge",
	-- Beastmen
	["dlc03_bst_khazrak"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["dlc03_bst_malagor"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["dlc05_bst_morghur"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["wh2_dlc17_bst_taurox"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	-- Greenskin
	["grn_grimgor_ironhide"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["grn_azhag_the_slaughterer"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["dlc06_grn_skarsnik"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["dlc06_grn_wurrzag_da_great_prophet"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["wh2_dlc15_grn_grom_the_paunch"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	-- Dark Elves
	["wh2_main_def_malekith"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["wh2_main_def_morathi"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["wh2_dlc10_def_crone_hellebron"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["wh2_dlc11_def_lokhir"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["wh2_dlc14_def_malus_darkblade"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge",
	["wh2_twa03_def_rakarth"] = "wh_dlc07_trait_brt_questing_vow_protect_pledge"
};

local vow_agents = {
	["brt_paladin"] = true,
	["wh2_dlc14_brt_henri_le_massif"] = true
};

function add_vow_progress(character, trait, ai, agents)
	if character:is_null_interface() == true then
		return false;
	end
	
	if ai == false and character:faction():is_human() == false then
		return false; -- Make sure AI doesn't get Vows when we don't want them to
	end
	local char_cqi = character:cqi();
	out.design("------------------------------------------------");
	out.design("add_vow_progress - "..char_cqi.." - "..trait.." - "..tostring(ai).." - "..tostring(agents));
	ai = ai or false;
	local max_trait_points = vow_max_points[trait] or 6;
	out.design("\tMax Points - "..max_trait_points);
	local incident = "wh_dlc07_incident_brt_vow_gained";
	local incident_uc = incident;
	local event_key = trait;
	local is_female = character:character_subtype("dlc07_brt_fay_enchantress")
		or character:character_subtype("dlc07_brt_prophetess_beasts")
		or character:character_subtype("dlc07_brt_prophetess_heavens")
		or character:character_subtype("dlc07_brt_prophetess_life");
	
	if is_female == true then
		out.design("\tFemale Character");
		trait = vow_to_troth[trait];
		out.design("\tTrait - "..trait);
		incident = incident.."_female";
		
		if trait:starts_with("wh_dlc07_trait_brt_virtue_troth") == true and character:character_subtype("dlc07_brt_fay_enchantress") == true then
			trait = trait.."_fay";
			out.design("\tFay Trait - "..trait);
		end
	end
	
	local faction_cqi = character:faction():command_queue_index();
	local points = character:trait_points(trait);
	out.design("\tPoints: "..points);
	
	if points > 0 or ai == true then
		if points < max_trait_points then
			out.design("\tAdding trait - "..trait);
			cm:force_add_trait("character_cqi:"..char_cqi, trait, false, 1, false);
			points = points + 1;
			out.design("\tNew Points: "..points);
			
			if points == max_trait_points and ai == false then
				out.design("\tTriggering event: "..char_cqi);
				cm:trigger_incident_with_targets(faction_cqi, incident, faction_cqi, 0, char_cqi, 0, 0, 0);
				
				if event_key:starts_with("wh_dlc07_trait_brt_knights_vow") then 
					core:trigger_event("ScriptEventBretonniaKnightsVowCompleted", character);
				elseif event_key:starts_with("wh_dlc07_trait_brt_questing_vow") then
					core:trigger_event("ScriptEventBretonniaQuestingVowCompleted", character);
				elseif event_key:starts_with("wh_dlc07_trait_brt_grail_vow") then
					core:trigger_event("ScriptEventBretonniaGrailVowCompleted", character);
				end
			end
		end
	end
	
	-- Do all Paladins in this characters army
	if agents == true and character:has_military_force() == true then
		trait = event_key.."_agent";
		local force_characters = character:military_force():character_list();
		local force_character_count = force_characters:num_items();
		out.design("Checking agents ("..force_character_count..")...")
		
		for i = 0, force_character_count - 1 do
			local current_char = force_characters:item_at(i);
			local subtype_key = current_char:character_subtype_key();
			out.design("\t\tCharacter: "..subtype_key);
			
			if vow_agents[subtype_key] == true then
				local agent_points = current_char:trait_points(trait);
				out.design("\t\t\tPoints: "..agent_points);
				
				if agent_points > 0 and agent_points < max_trait_points then
					out.design("\t\t\tAdding agent trait - "..trait);
					char_cqi = current_char:command_queue_index();
					cm:force_add_trait("character_cqi:"..char_cqi, trait, false, 1, false);
					agent_points = agent_points + 1;
					out.design("\t\t\tNew Points: "..agent_points);
					
					if agent_points == max_trait_points then
						out.design("\t\t\tTriggering event: "..char_cqi);
						cm:trigger_incident_with_targets(faction_cqi, incident_uc, faction_cqi, 0, char_cqi, 0, 0, 0);
					end
				end
			end
		end
	end
	out.design("------------------------------------------------");
end

function add_starting_vows()
	for i = 1, #starting_vows do
		local faction_key = starting_vows[i].faction;
		local traits = starting_vows[i].traits;
		
		local faction = cm:model():world():faction_by_key(faction_key);
		
		if faction:is_null_interface() == false then
			local faction_leader = faction:faction_leader();
			
			if faction_leader:is_null_interface() == false then
				for j = 1, #traits do
					for k = 1, traits[j].points do
						cm:force_add_trait("character_cqi:"..faction_leader:command_queue_index(), traits[j].key, false);
					end
				end
			end
		end
	end
end

-- Human characters get the Vows per level
core:add_listener(
		"character_rank_up_vows_per_level_human",
		"CharacterRankUp",
		true,
		function(context)
			local character = context:character();

			if character:faction():is_human() == true and character:faction():culture() == "wh_main_brt_bretonnia" then
				if character:character_type("general") == true then
					if character:rank() == 8 then
						for i = 1, 6 do
							add_vow_progress(character, "wh_dlc07_trait_brt_knights_vow_knowledge_pledge", true, true);
						end
					elseif character:rank() == 10 then
						for i = 1, 6 do
							add_vow_progress(character, "wh_dlc07_trait_brt_questing_vow_protect_pledge", true, true);
						end
					elseif character:rank() == 13 then
						for i = 1, 6 do
							add_vow_progress(character, "wh_dlc07_trait_brt_grail_vow_valour_pledge", true, true);
						end
					end
				end
			end
		end,
		true
);

-- AI characters get the Vows per level
core:add_listener(
	"character_rank_up_vows_per_level_ai",
	"CharacterRankUp",
	true,
	function(context)
		local character = context:character();
		
		if character:faction():is_human() == false and character:faction():culture() == "wh_main_brt_bretonnia" then
			if character:character_type("general") == true then
				if character:rank() == 2 then
					for i = 1, 6 do
						add_vow_progress(character, "wh_dlc07_trait_brt_knights_vow_knowledge_pledge", true, false);
					end
				elseif character:rank() == 5 then
					for i = 1, 6 do
						add_vow_progress(character, "wh_dlc07_trait_brt_questing_vow_protect_pledge", true, false);
					end
				elseif character:rank() == 10 then
					for i = 1, 6 do
						add_vow_progress(character, "wh_dlc07_trait_brt_grail_vow_valour_pledge", true, false);
					end
				end
			end
		end
	end,
	true
);

-- Allows player to skip the early Vows at high enough Chivalry
core:add_listener(
	"Vow_CharacterCreated",
	"CharacterCreated",
	true,
	function(context)
		local character = context:character();
		
		if character:character_type("general") == true then
			local faction = context:character():faction();
			
			if faction:is_human() == true and faction:culture() == "wh_main_brt_bretonnia" then
				if faction:has_effect_bundle("wh_dlc07_bretonnia_chivalry_bar_801_1000") == true then
					for i = 1, 6 do
						add_vow_progress(character, "wh_dlc07_trait_brt_knights_vow_knowledge_pledge", true, false);
					end
					for i = 1, 6 do
						add_vow_progress(character, "wh_dlc07_trait_brt_questing_vow_protect_pledge", true, false);
					end
				elseif faction:has_effect_bundle("wh_dlc07_bretonnia_chivalry_bar_601_800") == true then
					for i = 1, 6 do
						add_vow_progress(character, "wh_dlc07_trait_brt_knights_vow_knowledge_pledge", true, false);
					end
				elseif faction:has_effect_bundle("wh_dlc07_bretonnia_chivalry_bar_401_600") == true then
					for i = 1, 6 do
						add_vow_progress(character, "wh_dlc07_trait_brt_knights_vow_knowledge_pledge", true, false);
					end
				end
			end
		end
	end,
	true
);


-----------------------
----- KNIGHTS VOW -----
-----------------------

-- Pledge to Knowledge
core:add_listener(
	"research_completed_pledge_to_knowledge",
	"ResearchCompleted",
	true,
	function(context)
		local faction = context:faction();
		
		if faction:is_human() == true and faction:culture() == "wh_main_brt_bretonnia" then
			local character_list = faction:character_list();
			
			for i = 0, character_list:num_items() - 1 do
				local current_char = character_list:item_at(i);
				
				if cm:char_is_general_with_army(current_char) then
					add_vow_progress(current_char, "wh_dlc07_trait_brt_knights_vow_knowledge_pledge", false, false);
				end
			end
		end
	end,
	true
);

-- Pledge to Order
core:add_listener(
	"building_completed_pledge_to_knowledge",
	"BuildingCompleted",
	true,
	function(context)
		local building = context:building();
		local builder_fac = building:faction();
		
		if builder_fac:is_null_interface() == false and builder_fac:is_human() == true and builder_fac:culture() == "wh_main_brt_bretonnia" then
			local characters = builder_fac:character_list();
			
			for i = 0, characters:num_items() - 1 do
				local builder = characters:item_at(i);
				
				if builder:is_null_interface() == false and builder:has_region() == true and builder:region():name() == building:region():name() then
					local subtype_key = builder:character_subtype_key();

					if vow_agents[subtype_key] == true then
						add_vow_progress(builder, "wh_dlc07_trait_brt_knights_vow_order_pledge_agent", false, false);
					else
						add_vow_progress(builder, "wh_dlc07_trait_brt_knights_vow_order_pledge", false, false);
					end
				end
			end
		end
	end,
	true
);

-- Pledge to Chivalry
core:add_listener(
	"character_rank_up_pledge_to_chivalry",
	"CharacterRankUp",
	true,
	function(context)
		local character = context:character();

		if character:faction():is_human() == true and character:faction():culture() == "wh_main_brt_bretonnia" then
			local subtype_key = character:character_subtype_key();
			
			if character:character_type("general") == true then
				add_vow_progress(character, "wh_dlc07_trait_brt_knights_vow_chivalry_pledge", false, false);
			elseif vow_agents[subtype_key] == true then
				local trait = "wh_dlc07_trait_brt_knights_vow_chivalry_pledge_agent";
				local agent_points = character:trait_points(trait);
				
				if agent_points > 0 then
					cm:force_add_trait("character_cqi:"..character:cqi(), trait, false);
				end
			end
		end
	end,
	true
);

-- Pledge to Knowledge (Agent)
core:add_listener(
	"character_character_target_action_pledge_to_knowledge",
	"CharacterCharacterTargetAction",
	true,
	function(context)
		if context:mission_result_critial_success() or context:mission_result_success() then
			local character = context:character();
			local subtype_key = character:character_subtype_key();
			local trait = "wh_dlc07_trait_brt_knights_vow_knowledge_pledge_agent";
			
			if vow_agents[subtype_key] == true then
				local agent_points = character:trait_points(trait);
				
				if agent_points > 0 then
					cm:force_add_trait("character_cqi:"..character:cqi(), trait, false);
				end
			end
		end
	end,
	true
);
core:add_listener(
	"character_garrison_target_action_pledge_to_knowledge",
	"CharacterGarrisonTargetAction",
	true,
	function(context)
		if context:mission_result_critial_success() or context:mission_result_success() then
			local character = context:character();
			local subtype_key = character:character_subtype_key();
			local trait = "wh_dlc07_trait_brt_knights_vow_knowledge_pledge_agent";
			
			if vow_agents[subtype_key] == true then
				local agent_points = character:trait_points(trait);
				
				if agent_points > 0 then
					cm:force_add_trait("character_cqi:"..character:cqi(), trait, false);
				end
			end
		end
	end,
	true
);

------------------------
----- QUESTING VOW -----
------------------------

-- Pledge to Campaign
core:add_listener(
	"character_performs_settlement_occupation_decision_pledge_to_campaign",
	"CharacterPerformsSettlementOccupationDecision",
	true,
	function(context)
		local character = context:character();
		
		if character:faction():is_human() == true and character:faction():culture() == "wh_main_brt_bretonnia" then
			local settlement = context:garrison_residence():settlement_interface();
			
			--if settlement:region():is_province_capital() == true then
				local climate = settlement:get_climate();
				
				if climate == "climate_desert" or climate == "climate_jungle" then
					add_vow_progress(character, "wh_dlc07_trait_brt_questing_vow_campaign_pledge", false, true);
				end
			--end
		end
	end,
	true
);

-- Pledge to Manann
core:add_listener(
	"character_completed_battle_pledge_to_heroism",
	"CharacterCompletedBattle",
	true,
	function(context)
		local pending_battle = cm:model():pending_battle();
		
		if pending_battle:is_active() == true then
			local attacker = pending_battle:attacker();
			local defender = pending_battle:defender();
			
			if cm:pending_battle_cache_attacker_victory() == true and attacker:is_null_interface() == false and attacker:faction():is_human() == true and attacker:is_at_sea() == true and attacker:faction():culture() == "wh_main_brt_bretonnia" then
				add_vow_progress(attacker, "wh_dlc07_trait_brt_questing_vow_heroism_pledge", false, true);
			elseif cm:pending_battle_cache_defender_victory() == true and defender:is_null_interface() == false and defender:faction():is_human() == true and defender:is_at_sea() == true and defender:faction():culture() == "wh_main_brt_bretonnia" then
				add_vow_progress(defender, "wh_dlc07_trait_brt_questing_vow_heroism_pledge", false, true);
			end
		end
	end,
	true
);

---------------------
----- GRAIL VOW -----
---------------------

-- Pledge to Valour
-- Pledge to Protect
-- Pledge to Untaint
core:add_listener(
	"character_convalesced_or_killed_grail_vow",
	"CharacterConvalescedOrKilled",
	true,
	function(context)
		local character = context:character();
		
		if character:is_null_interface() == false and character:character_type("general") == true and character:has_military_force() == true and character:military_force():is_armed_citizenry() == false then
			local dead_subtype = character:character_subtype_key();
			local dead_character_vow = vow_lords[dead_subtype];
			local pending_battle = cm:model():pending_battle();
			
			if cm:pending_battle_cache_attacker_victory() == true then
				for i = 1, cm:pending_battle_cache_num_attackers() do
					local char_cqi, mf_cqi, faction_name = cm:pending_battle_cache_get_attacker(i);
					local attacker = cm:model():character_for_command_queue_index(char_cqi);
					
					if attacker:is_null_interface() == false and attacker:faction():culture() == "wh_main_brt_bretonnia" then
						add_vow_progress(attacker, "wh_dlc07_trait_brt_grail_vow_valour_pledge", false, true);
					end
					
					if dead_character_vow ~= nil then
						add_vow_progress(attacker, dead_character_vow, false, true);
					end
				end
			else
				for i = 1, cm:pending_battle_cache_num_defenders() do
					local char_cqi, mf_cqi, faction_name = cm:pending_battle_cache_get_defender(i);
					local defender = cm:model():character_for_command_queue_index(char_cqi);
					
					if defender:is_null_interface() == false and defender:faction():culture() == "wh_main_brt_bretonnia" then
						add_vow_progress(defender, "wh_dlc07_trait_brt_grail_vow_valour_pledge", false, true);
					end
					
					if dead_character_vow ~= nil then
						add_vow_progress(defender, dead_character_vow, false, true);
					end
				end
			end
		end
	end,
	true
);

-- Pledge to Destroy
core:add_listener(
	"character_razed_setlement_pledge_to_destroy",
	"CharacterRazedSettlement",
	true,
	function(context)
		local character = context:character();
		
		if character:faction():is_human() == true and character:faction():culture() == "wh_main_brt_bretonnia" then
			if context:garrison_residence():region():is_province_capital() == true then
				add_vow_progress(character, "wh_dlc07_trait_brt_grail_vow_destroy_pledge", false, true);
			end
		end
	end,
	true
);
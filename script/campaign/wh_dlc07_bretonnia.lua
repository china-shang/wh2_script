BRETONNIA_FACTIONS = {
	["wh_main_brt_bretonnia"] = true,
	["wh_main_brt_carcassonne"] = true,
	["wh_main_brt_bordeleaux"] = true,
	["wh2_dlc14_brt_chevaliers_de_lyonesse"] = true
};
CHIVALRY_REQUIRED_FOR_VICTORY = 2000;
CHAPTER_1_CHIVALRY_REQUIREMENT = 800;
CHAPTER_2_CHIVALRY_REQUIREMENT = 1200;
CHAPTER_3_CHIVALRY_REQUIREMENT = 1600;
FINAL_BATTLE_DILEMMA = "wh_dlc07_brt_final_battle_choice";
FINAL_BATTLE_CHOICE_1 = "wh_dlc07_qb_brt_louen_errantry_war_chaos_wastes_stage_1_cliff_of_beasts";
FINAL_BATTLE_CHOICE_2 = "wh_dlc07_qb_brt_louen_errantry_war_badlands_stage_1_the_lost_idol";
FINAL_BATTLE_DILEMMA_REPANSE = "wh2_dlc14_main_brt_repanse_final_battle_choice";
FINAL_BATTLE_REPANSE_CHOICE_1 = "wh2_dlc14_main_brt_repanse_defend_or_conquer_crusader_stage_1";
FINAL_BATTLE_REPANSE_CHOICE_2 = "wh2_dlc14_main_brt_repanse_defend_or_conquer_guardian_stage_1";
FINAL_BATTLE_VOR_DILEMMA_REPANSE = "wh2_dlc14_vortex_brt_repanse_final_battle_choice";
FINAL_BATTLE_VOR_REPANSE_CHOICE_1 = "wh2_dlc14_vortex_brt_repanse_defend_or_conquer_crusader_stage_1";
FINAL_BATTLE_VOR_REPANSE_CHOICE_2 = "wh2_dlc14_vortex_brt_repanse_defend_or_conquer_guardian_stage_1";

function Add_Bretonnia_Listeners()
	out("#### Adding Bretonnia Listeners ####");
	core:add_listener(
		"Bret_MissionSucceeded",
		"MissionSucceeded",
		true,
		function(context) Bret_MissionSucceeded(context) end,
		true
	);

	if cm:is_multiplayer() == false then
		-- Start a FactionTurnStart listener for each Bretonnian faction
		for faction_key in pairs(BRETONNIA_FACTIONS) do
			cm:add_faction_turn_start_listener_by_name(
				"Bret_FactionTurnStart",
				faction_key,
				function(context)
					Bret_FactionTurnStart(context); 
				end,
				true
			);
		end;
		core:add_listener(
			"Bret_FactionTurnEnd",
			"FactionTurnEnd",
			true,
			function(context) Bret_FactionTurnEnd(context) end,
			true
		);

		core:add_listener(
			"Bret_DilemmaChoiceMadeEvent",
			"DilemmaChoiceMadeEvent",
			true,
			function(context) Bret_DilemmaChoiceMadeEvent(context) end,
			true
		);
	end

	core:add_listener(
		"Bret_StartCharacterRazedSettlement",
		"CharacterRazedSettlement",
		true,
		function(context) Bret_StartCharacterRazedSettlement(context) end,
		true
	);

	core:add_listener(
		"Bret_StartCharacterOccupiesSettlement",
		"GarrisonOccupiedEvent",
		true,
		function(context) Bret_StartCharacterRazedSettlement(context) end,
		true
	);

	core:add_listener(
		"Bret_CharacterEntersGarrison",
		"CharacterEntersGarrison",
		true,
		function(context) Bret_RepanseSupplies(context:character(), false) end,
		true
	);
	core:add_listener(
		"Bret_CharacterLeavesGarrison",
		"CharacterLeavesGarrison",
		true,
		function(context) Bret_RepanseSupplies(context:character(), true) end,
		true
	);

	core:add_listener(
		"Bret_CharacterTurnStart",
		"CharacterTurnStart",
		true,
		function(context) Bret_RepanseSupplies(context:character(), false) end,
		true
	);

	-- Start a FactionTurnStart listener for each Bretonnian faction
	for faction_key in pairs(BRETONNIA_FACTIONS) do
		cm:add_faction_turn_start_listener_by_name(
			"Bret_FactionTurnStart2",
			faction_key,
			function(context)
				RepanseBannerTurnStart(context); 
			end,
			true
		);
	end;

	if cm:is_new_game() == true then
		local kemmler = cm:model():world():faction_by_key("wh2_dlc11_vmp_the_barrow_legion");
		
		if kemmler:is_null_interface() == false and kemmler:is_human() == false then
			cm:apply_effect_bundle("wh2_main_ai_kemmler", "wh2_dlc11_vmp_the_barrow_legion", 50);
			cm:force_religion_factors("wh_main_forest_of_arden_castle_artois", "wh_main_religion_undeath", 0.0, "wh_main_religion_untainted", 1.0);
			cm:teleport_to("character_cqi:"..kemmler:faction_leader():command_queue_index(), 433, 431, true);
		end
	end
end

function Bret_MissionSucceeded(context)
	local mission_key = context:mission():mission_record_key();
	local faction_key = context:faction():name();
	
	if Is_Bretonnian(faction_key) then		
		------------------------------------------
		---- ERRANTRY WAR - VICTORY CONDITION ----
		------------------------------------------
		if mission_key == FINAL_BATTLE_CHOICE_1 or mission_key == FINAL_BATTLE_CHOICE_2 or mission_key == FINAL_BATTLE_REPANSE_CHOICE_1 or mission_key == FINAL_BATTLE_REPANSE_CHOICE_2 or mission_key == FINAL_BATTLE_VOR_REPANSE_CHOICE_1 or mission_key == FINAL_BATTLE_VOR_REPANSE_CHOICE_2 then
			cm:complete_scripted_mission_objective("wh_main_long_victory", "win_errantry_war", true);
		end
		----------------------------------
		---- ERRANTRY WAR - CHAPTER 1 ----
		----------------------------------
		if mission_key == ("wh_dlc07_objective_01_"..faction_key) then
			cm:trigger_mission(faction_key, "wh_dlc07_objective_02_"..faction_key, true);
		----------------------------------
		---- ERRANTRY WAR - CHAPTER 2 ----
		----------------------------------
		elseif mission_key == ("wh_dlc07_objective_02_"..faction_key) then
			cm:trigger_mission(faction_key, "wh_dlc07_objective_03_"..faction_key, true);
		----------------------------------
		---- ERRANTRY WAR - CHAPTER 3 ----
		----------------------------------
		elseif mission_key == ("wh_dlc07_objective_03_"..faction_key) and faction_key ~="wh2_dlc14_brt_chevaliers_de_lyonesse"  then
			cm:trigger_dilemma(
				faction_key, 
				FINAL_BATTLE_DILEMMA,
				function()
					core:trigger_event("ScriptEventErrantryWarDilemma");
				end
			);
		elseif mission_key == ("wh_dlc07_objective_03_"..faction_key) and faction_key == "wh2_dlc14_brt_chevaliers_de_lyonesse"  then
			cm:trigger_dilemma(
				faction_key, 
				FINAL_BATTLE_DILEMMA_REPANSE,
				function()
					core:trigger_event("ScriptEventErrantryWarDilemma");
				end
			);
		end
	end
end

function Bret_FactionTurnStart(context)	
	Check_Chivalry_Win_Condition(context:faction());
end

function RepanseBannerTurnStart(context)
	local faction = context:faction()
	local faction_key = faction:name();
	local turn_number = cm:model():turn_number();
	
	-- now checked by the listener
	if faction:is_human() == true then
		if turn_number == 1 then
			if faction_key == "wh2_dlc14_brt_chevaliers_de_lyonesse" then
				cm:trigger_mission(faction_key, "wh2_dlc14_vor_brt_repanse_banner_jean", true);
				cm:trigger_mission(faction_key, "wh2_dlc14_vor_brt_repanse_banner_rene", true);
				cm:trigger_mission(faction_key, "wh2_dlc14_vor_brt_repanse_banner_pierre", true);
			end
		elseif turn_number == 2 then
			if faction_key == "wh2_dlc14_brt_chevaliers_de_lyonesse" then
				cm:trigger_incident(faction_key, "wh2_dlc14_incident_brt_desert_supplies", true);
			else
				cm:trigger_incident(faction_key, "wh_dlc07_incident_greenskin_rebelions", true);
			end
		elseif turn_number == 5 then
			if faction_key == "wh2_dlc14_brt_chevaliers_de_lyonesse" then
				if cm:get_campaign_name() == "main_warhammer" then
					cm:trigger_mission(faction_key, "wh2_dlc14_brt_repanse_capture_arkhan", true);
				else
					cm:trigger_mission(faction_key, "wh2_dlc14_vor_brt_repanse_capture_arkhan", true);
				end
			end
		elseif turn_number == 10 then
			if faction_key == "wh2_dlc14_brt_chevaliers_de_lyonesse" then
				if cm:get_campaign_name() == "main_warhammer" then
					cm:trigger_mission(faction_key, "wh2_dlc14_brt_repanse_capture_rakaph", true);
				else
					cm:trigger_mission(faction_key, "wh2_dlc14_vor_brt_repanse_capture_rakaph", true);
				end
			end
		elseif turn_number == 20 then
			if faction_key == "wh2_dlc14_brt_chevaliers_de_lyonesse" then
				if cm:get_campaign_name() == "main_warhammer" then
					cm:trigger_mission(faction_key, "wh2_dlc14_brt_repanse_capture_nagash", true);
				else
					cm:trigger_mission(faction_key, "wh2_dlc14_vor_brt_repanse_capture_nagash", true);
				end
			end
		end
	end
end

function Bret_FactionTurnEnd(context)
	Check_Chivalry_Win_Condition(context:faction());
end

function Check_Chivalry_Win_Condition(faction)
	local faction_key = faction:name();
	
	if Is_Bretonnian(faction_key) then
		local chivalry_amount = faction:total_food();
		
		if chivalry_amount >= CHAPTER_3_CHIVALRY_REQUIREMENT then
			-- CHAPTER 3 OBJECTIVE TO ATTAIN A CERTAIN CHIVALRY LEVEL
			cm:complete_scripted_mission_objective("wh_dlc07_objective_03_"..faction_key, "gain_chapter_chivalry_"..faction_key, true);
		end
		if chivalry_amount >= CHAPTER_2_CHIVALRY_REQUIREMENT then
			-- CHAPTER 2 OBJECTIVE TO ATTAIN A CERTAIN CHIVALRY LEVEL
			cm:complete_scripted_mission_objective("wh_dlc07_objective_02_"..faction_key, "gain_chapter_chivalry_"..faction_key, true);
		end
		if chivalry_amount >= CHAPTER_1_CHIVALRY_REQUIREMENT then
			-- CHAPTER 1 OBJECTIVE TO ATTAIN A CERTAIN CHIVALRY LEVEL
			cm:complete_scripted_mission_objective("wh_dlc07_objective_01_"..faction_key, "gain_chapter_chivalry_"..faction_key, true);
		end
	
		if chivalry_amount >= CHIVALRY_REQUIRED_FOR_VICTORY then
			-- VICTORY CONDITION TO ATTAIN A CERTAIN CHIVALRY LEVEL
			cm:complete_scripted_mission_objective("wh_main_long_victory", "attain_chivalry_1000", true); -- support for old save games where the key was not updated
			cm:complete_scripted_mission_objective("wh_main_long_victory", "attain_chivalry_2000", true);
		end
		
		if chivalry_amount >= CHIVALRY_REQUIRED_FOR_VICTORY and cm:get_campaign_name() == "wh2_main_great_vortex" then
			-- VICTORY CONDITION TO ATTAIN A CERTAIN CHIVALRY LEVEL
			cm:complete_scripted_mission_objective("wh_main_long_victory", "attain_chivalry_1000", true); -- support for old save games where the key was not updated
			cm:complete_scripted_mission_objective("wh_main_long_victory", "attain_chivalry_2000", true);
			cm:trigger_dilemma(
				faction_key, 
				FINAL_BATTLE_VOR_DILEMMA_REPANSE,
				function()
					core:trigger_event("ScriptEventErrantryWarDilemma");
				end
			);
		end
	end
end

function Bret_DilemmaChoiceMadeEvent(context)
	local faction_key = context:faction():name();
	local dilemma = context:dilemma();
	local choice = context:choice();
	
	if dilemma == FINAL_BATTLE_DILEMMA then
		if choice == 0 then
			cm:trigger_mission(faction_key, FINAL_BATTLE_CHOICE_1, true);
		else
			cm:trigger_mission(faction_key, FINAL_BATTLE_CHOICE_2, true);
		end
	elseif dilemma == FINAL_BATTLE_DILEMMA_REPANSE then
		if choice == 0 then
			cm:trigger_mission(faction_key, FINAL_BATTLE_REPANSE_CHOICE_1, true);
		else
			cm:trigger_mission(faction_key, FINAL_BATTLE_REPANSE_CHOICE_2, true);
		end
	elseif dilemma == FINAL_BATTLE_VOR_DILEMMA_REPANSE then
		if choice == 0 then
			cm:trigger_mission(faction_key, FINAL_BATTLE_VOR_REPANSE_CHOICE_1, true);
		else
			cm:trigger_mission(faction_key, FINAL_BATTLE_VOR_REPANSE_CHOICE_2, true);
		end
	end
end

function Bret_StartCharacterRazedSettlement(context)
	local faction_key = context:character():faction():name();
	
	if Is_Bretonnian(faction_key) then
		local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(1);
		local razed_faction = cm:model():world():faction_by_key(defender_name);
		
		if razed_faction:is_null_interface() == false then
			local razed_sc = razed_faction:subculture();
			if razed_sc == "wh_main_sc_grn_greenskins" then
				cm:remove_effect_bundle("wh_dlc07_greenskins_incursions", faction_key);
			end
		end
	end
end

function Bret_RepanseSupplies(character, leaving)
	if character:faction():name() == "wh2_dlc14_brt_chevaliers_de_lyonesse" and (character:in_settlement() == true or leaving == true) then
		local character_cqi = character:command_queue_index();

		cm:remove_effect_bundle_from_characters_force("wh2_dlc14_bundle_desert_supplies", character_cqi);
		cm:apply_effect_bundle_to_characters_force("wh2_dlc14_bundle_desert_supplies", character_cqi, 5, false);
	end
end

function Is_Bretonnian(faction_key)
	return BRETONNIA_FACTIONS[faction_key] ~= nil;
end
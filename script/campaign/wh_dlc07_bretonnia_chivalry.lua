CHIVALRY_THRESHOLDS = {
	200, 400, 600, 800
};

CHIVALRY_BATTLE_RESULT_VALUES = {
	["heroic_victory"] = 30,
	["decisive_victory"] = 10,
	["close_victory"] = 5,
	["pyrrhic_victory"] = 2,
	["valiant_defeat"] = -2,
	["close_defeat"] = -5,
	["decisive_defeat"] = -10,
	["crushing_defeat"] = -20
};

CHIVALRY_EVENT_PAYLOADS = {
	["dilemmas"] = {
		["wh_dlc07_brt_the_price_of_chivalry"] = {20, 20, 0},
		["wh_dlc07_brt_qb_alberic_trident_of_manann_stage_5"] = {0, -20, 0},
		["wh_dlc07_brt_confederation_artois"] = {-70, 0, 20},
		["wh_dlc07_brt_confederation_bastonne"] = {-70, 0, 20},
		["wh_dlc07_brt_confederation_bordeleaux"] = {-100, 0, 20},
		["wh_dlc07_brt_confederation_bretonnia"] = {-100, 0, 20},
		["wh_dlc07_brt_confederation_carcassonne"] = {-100, 20, 20},
		["wh_dlc07_brt_confederation_lyonesse"] = {-70, 0, 20},
		["wh_dlc07_brt_confederation_parravon"] = {-70, 0, 20}
	},
	["incidents"] = {
		["wh_dlc07_incident_brt_grandiose_tournament"] = 20,
		["wh_dlc07_incident_brt_not_very_noble"] = -20
	}
};

CHIVALRY_TECH_BONUSES = {
	["tech_dlc07_brt_chivalry_greenskins_1"] = 2,
	["tech_dlc07_brt_chivalry_greenskins_2"] = 5,
	["tech_dlc07_brt_chivalry_beastmen_1"] = 2,
	["tech_dlc07_brt_chivalry_chaos_1"] = 2,
	["tech_dlc07_brt_chivalry_norsca_1"] = 2,
	["tech_dlc07_brt_chivalry_norsca_2"] = 5,
	["tech_dlc07_brt_chivalry_vampires_1"] = 2,
	["tech_dlc07_brt_chivalry_wood_elves_1"] = 2,
	["tech_dlc07_brt_chivalry_dark_elves_1"] = 2,
	["tech_dlc07_brt_chivalry_skaven_1"] = 2,
	["tech_dlc07_brt_chivalry_tomb_kings_1"] = 2,
	["tech_dcl14_brt_chivalry_tomb_kings_2"] = 3,
	["tech_dlc11_brt_chivalry_vampire_coast_1"] = 2
};

CHIVALRY_TRAITS = {
	--------------------
	---- BAD TRAITS ----
	--------------------
	["wh_dlc07_trait_brt_lord_bad_abducter"] = {
		levels = {
			{level = 1, points = 5, chivalry = -20}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_attacker"] = {
		levels = {
			{level = 1, points = 4, chivalry = -20},
			{level = 2, points = 7, chivalry = -50},
			{level = 3, points = 10, chivalry = -100}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_coward"] = {
		levels = {
			{level = 1, points = 5, chivalry = -20}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_defeat"] = {
		levels = {
			{level = 1, points = 1, chivalry = -50},
			{level = 2, points = 3, chivalry = -100}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_defender"] = {
		levels = {
			{level = 1, points = 3, chivalry = -20},
			{level = 2, points = 5, chivalry = -50},
			{level = 3, points = 7, chivalry = -100}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_kingslayer"] = {
		levels = {
			{level = 1, points = 1, chivalry = -100}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_lazy"] = {
		levels = {
			{level = 1, points = 1, chivalry = -20},
			{level = 2, points = 2, chivalry = -50}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_perverted"] = {
		levels = {
			{level = 1, points = 3, chivalry = -20}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_raider"] = {
		levels = {
			{level = 1, points = 5, chivalry = -20}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_renegade"] = {
		levels = {
			{level = 1, points = 3, chivalry = -20}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_sacking"] = {
		levels = {
			{level = 1, points = 3, chivalry = -50},
			{level = 2, points = 6, chivalry = -100},
			{level = 3, points = 9, chivalry = -200}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_scared_of_beastmen"] = {
		levels = {
			{level = 1, points = 4, chivalry = -20}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_scared_of_chaos"] = {
		levels = {
			{level = 1, points = 4, chivalry = -20}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_scared_of_greenskins"] = {
		levels = {
			{level = 1, points = 4, chivalry = -20}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_scared_of_vampires"] = {
		levels = {
			{level = 1, points = 4, chivalry = -20}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_sieging"] = {
		levels = {
			{level = 1, points = 3, chivalry = -20},
			{level = 2, points = 5, chivalry = -50},
			{level = 3, points = 7, chivalry = -100}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_traitor"] = {
		levels = {
			{level = 1, points = 1, chivalry = -50}
		}
	},
	["wh_dlc07_trait_brt_lord_bad_villain"] = {
		levels = {
			{level = 1, points = 3, chivalry = -20}
		}
	},
	
	---------------------
	---- GOOD TRAITS ----
	---------------------
	["wh_dlc07_trait_brt_lord_good_attacker"] = {
		levels = {
			{level = 1, points = 6, chivalry = 10},
			{level = 2, points = 11, chivalry = 30},
			{level = 3, points = 16, chivalry = 50}
		}
	},
	["wh_dlc07_trait_brt_lord_good_beastmen"] = {
		levels = {
			{level = 1, points = 10, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_chaos"] = {
		levels = {
			{level = 1, points = 10, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_defeated_archaon"] = {
		levels = {
			{level = 1, points = 1, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_defeated_grimgor"] = {
		levels = {
			{level = 1, points = 1, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_defeated_khazrak"] = {
		levels = {
			{level = 1, points = 1, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_defeated_manfred"] = {
		levels = {
			{level = 1, points = 1, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_defender"] = {
		levels = {
			{level = 1, points = 4, chivalry = 10},
			{level = 2, points = 7, chivalry = 30},
			{level = 3, points = 10, chivalry = 50}
		}
	},
	["wh_dlc07_trait_brt_lord_good_executing"] = {
		levels = {
			{level = 1, points = 10, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_far_from_capital"] = {
		levels = {
			{level = 1, points = 6, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_farming"] = {
		levels = {
			{level = 1, points = 5, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_greenskins"] = {
		levels = {
			{level = 1, points = 10, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_industry"] = {
		levels = {
			{level = 1, points = 5, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_knightly"] = {
		levels = {
			{level = 1, points = 6, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_lone_wolf"] = {
		levels = {
			{level = 1, points = 1, chivalry = 10},
			{level = 2, points = 2, chivalry = 30}
		}
	},
	["wh_dlc07_trait_brt_lord_good_peasants"] = {
		levels = {
			{level = 1, points = 6, chivalry = 5}
		}
	},
	["wh_dlc07_trait_brt_lord_good_praying"] = {
		levels = {
			{level = 1, points = 1, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_public_order"] = {
		levels = {
			{level = 1, points = 10, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_reinforcing"] = {
		levels = {
			{level = 1, points = 4, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_sieging"] = {
		levels = {
			{level = 1, points = 4, chivalry = 10},
			{level = 2, points = 7, chivalry = 30},
			{level = 3, points = 10, chivalry = 50}
		}
	},
	["wh_dlc07_trait_brt_lord_good_vampires"] = {
		levels = {
			{level = 1, points = 10, chivalry = 10}
		}
	},
	["wh_dlc07_trait_brt_lord_good_victory"] = {
		levels = {
			{level = 1, points = 1, chivalry = 10},
			{level = 2, points = 4, chivalry = 30},
			{level = 3, points = 10, chivalry = 50}
		}
	}
};

CHIVALRY_SKILLS = {
	{skill = "wh_dlc07_skill_brt_innate_fay_enchantress", value = 10},
	{skill = "wh2_dlc14_skill_innate_brt_henri_le_massif", value = 10},
	{skill = "wh2_dlc14_skill_innate_brt_repanse", value = 10},
	{skill = "wh_main_skill_innate_brt_louen_leoncouer", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_audacity", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_confidence", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_discipline", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_duty", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_heroism", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_ideal", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_impetuous_knight", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_joust", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_knightly_temper", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_noble_disdain", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_penitent", value = 10},
	{skill = "wh_main_skill_innate_brt_virtue_stoicism", value = 10},
	{skill = "wh_dlc07_brt_skill_innate_all_honourable", value = 5},
	{skill = "wh_dlc07_brt_skill_innate_all_intelligent", value = 5},
	{skill = "wh_dlc07_brt_skill_innate_all_magnanimous", value = 5},
	{skill = "wh_dlc07_brt_skill_innate_all_melancholic", value = 5},
	{skill = "wh_dlc07_brt_skill_innate_all_phlegmatic", value = 5},
	{skill = "wh_dlc07_brt_skill_innate_all_sanguine", value = 5},
	{skill = "wh_dlc07_brt_skill_innate_all_uncompromising", value = 5},
	{skill = "wh2_dlc07_skill_brt_louen_special_3", value = 15}
};

CHIVALRY_QUESTS = {
	["wh_dlc07_qb_brt_louen_errantry_war_badlands_stage_1_the_lost_idol"] = 20,
	["wh_dlc07_qb_brt_louen_errantry_war_chaos_wastes_stage_1_cliff_of_beasts"] = 20,
	["wh_dlc07_qb_brt_louen_sword_of_couronne_stage_4_la_maisontaal_abbey"] = 20,
	["wh_dlc07_qb_brt_fay_enchantress_chalice_of_potions_stage_6"] = 20,
	["wh_dlc07_qb_brt_alberic_trident_of_bordeleaux_stage_8_estalian_tomb"] = 20,
	["wh2_dlc14_main_brt_repanse_defend_or_conquer_crusader_stage_1"] = 20,
	["wh2_dlc14_main_brt_repanse_defend_or_conquer_guardian_stage_1"] = 20,
	["wh2_dlc14_vortex_brt_repanse_defend_or_conquer_crusader_stage_1"] = 20,
	["wh2_dlc14_brt_repanse_capture_arkhan"] = 20,
	["wh2_dlc14_brt_repanse_capture_nagash"] = 20,
	["wh2_dlc14_brt_repanse_capture_rakaph"] = 20,
	["wh2_dlc14_vor_brt_repanse_capture_arkhan"] = 20,
	["wh2_dlc14_vor_brt_repanse_capture_nagash"] = 20,
	["wh2_dlc14_vor_brt_repanse_capture_rakaph"] = 20,
	["wh2_dlc14_repanse_mission_own_province"] = 20,
	["wh2_dlc14_brt_repanse_raze_orcs"] = 20,
	["wh2_dlc14_brt_repanse_banner_jean_alternate"] = 20,
	["wh2_dlc14_vor_brt_repanse_banner_jean"] = 20,
	["wh2_dlc14_vor_brt_repanse_banner_pierre"] = 20,
	["wh2_dlc14_vor_brt_repanse_banner_rene"] = 20
};

CHIVALRY_BATTLE_FACTOR = "wh_dlc07_chivalry_battle_";
CHIVALRY_EVENT_FACTOR = "wh_dlc07_chivalry_events";
CHIVALRY_GOOD_TRAIT_FACTOR = "wh_dlc07_chivalry_traits_good";
CHIVALRY_BAD_TRAIT_FACTOR = "wh_dlc07_chivalry_traits_bad";

CHIVALRY_BRETONNIAN_WAR_FACTOR = "wh_dlc07_chivalry_war";
CHIVALRY_BRETONNIAN_WAR_VALUE = -200;

CHIVALRY_SACKING_FACTOR = "wh_dlc07_chivalry_sacking";
CHIVALRY_SACKING_VALUE = -30;

CHIVALRY_RAZING_FACTOR = "wh_dlc07_chivalry_razing";
CHIVALRY_RAZING_VALUE_ENEMY = 30;
CHIVALRY_RAZING_VALUE_HUMANS = -100;

CHIVALRY_RAIDING_FACTOR = "wh_dlc07_chivalry_raiding";
CHIVALRY_RAIDING_VALUE = -2;

CHIVALRY_AMBUSHING_FACTOR = "wh_dlc07_chivalry_ambushing";
CHIVALRY_AMBUSHING_VALUE = -2;

CHIVALRY_RANSOM_FACTOR = "wh_dlc07_chivalry_ransom";
CHIVARLY_RANSOM_VALUE = -5;

CHIVALRY_LAST_ATTACKED_GARRISON = "";

function Add_Chivalry_Listeners()
	out("#### Adding Chivalry Listeners ####");
	core:add_listener(
		"Bret_BattleCompleted",
		"BattleCompleted",
		function() return cm:model():pending_battle():has_been_fought() end,
		function(context) Bret_BattleCompleted(context) end,
		true
	);

	-- start a FactionTurnStart listener for each Bretonnian faction
	for faction_key in pairs(BRETONNIA_FACTIONS) do
		cm:add_faction_turn_start_listener_by_name(
			"Bret_ChivalryFactionTurnStart",
			faction_key,
			function(context) 
				Bret_ChivalryFactionTurnStart(context) 
			end,
			true
		);
	end;

	core:add_listener(
		"Bret_ChivalryMilitaryForceCreated",
		"MilitaryForceCreated",
		true,
		function(context) Bret_ChivalryMilitaryForceCreated(context) end,
		true
	);
	core:add_listener(
		"Bret_CharacterTurnEnd",
		"CharacterTurnEnd",
		true,
		function(context) Bret_CharacterTurnEnd(context) end,
		true
	);
	core:add_listener(
		"Bret_CharacterPostBattleRelease",
		"CharacterPostBattleRelease",
		true,
		function(context) Bret_CharacterPostBattleRelease(context) end,
		true
	);
	core:add_listener(
		"Bret_CharacterSackedSettlement",
		"CharacterSackedSettlement",
		true,
		function(context) Bret_CharacterSackedSettlement(context) end,
		true
	);
	core:add_listener(
		"Bret_CharacterRazedSettlement",
		"CharacterRazedSettlement",
		true,
		function(context) Bret_CharacterRazedSettlement(context) end,
		true
	);
	core:add_listener(
		"Bret_IncidentOccuredEvent",
		"IncidentOccuredEvent",
		true,
		function(context) Bret_IncidentOccuredEvent(context) end,
		true
	);
	core:add_listener(
		"Bret_ChivalryDilemmaChoiceMadeEvent",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) Bret_ChivalryDilemmaChoiceMadeEvent(context) end,
		true
	);
	core:add_listener(
		"Bret_ChivalryVariationMonitor",
		"ScriptEventHumanFactionTurnStart",
		true,
		function(context) Bret_ChivalryVariationMonitor(context) end,
		true
	);
	core:add_listener(
		"Bret_NegativeDiplomaticEvent",
		"NegativeDiplomaticEvent",
		true,
		function(context) Bret_NegativeDiplomaticEvent(context) end,
		true
	);
	core:add_listener(
		"Bret_Quests_MissionSucceeded",
		"MissionSucceeded",
		true,
		function(context) Bret_Quests_MissionSucceeded(context) end,
		true
	);
	core:add_listener(
		"Bret_GarrisonAttackedEvent",
		"GarrisonAttackedEvent",
		true,
		function(context) Bret_GarrisonAttackedEvent(context) end,
		true
	);
	
	if cm:is_new_game() == true then
		local bretonnia = cm:model():world():faction_by_key("wh_main_brt_bretonnia");
		
		if bretonnia:is_null_interface() == false and bretonnia:is_human() then
			CalculateChivalryTraitsForFaction(bretonnia);
		end
		
		local carcassonne = cm:model():world():faction_by_key("wh_main_brt_carcassonne");
		
		if carcassonne:is_null_interface() == false and carcassonne:is_human() then
			CalculateChivalryTraitsForFaction(carcassonne);
		end
		
		local bordeleaux = cm:model():world():faction_by_key("wh_main_brt_bordeleaux");
		
		if bordeleaux:is_null_interface() == false and bordeleaux:is_human() then
			CalculateChivalryTraitsForFaction(bordeleaux);
		end
	end
end

function Bret_GarrisonAttackedEvent(context)
	CHIVALRY_LAST_ATTACKED_GARRISON = "";
	if context:garrison_residence():is_null_interface() == false then
		if context:garrison_residence():faction():is_null_interface() == false then
			CHIVALRY_LAST_ATTACKED_GARRISON = context:garrison_residence():faction():name();
		end
	end
end

-- BATTLES
function Bret_BattleCompleted(context)
	local num_attackers = cm:pending_battle_cache_num_attackers();
	local num_defenders = cm:pending_battle_cache_num_defenders();
	
	if num_attackers < 1 or num_defenders < 1 then
		return false;
	end
	
	--------------------------------------------------
	---- MAKE A LIST OF BRETONNIANS IN THE BATTLE ----
	--------------------------------------------------
	local bret_attackers = {};
	local bret_defenders = {};
	
	for i = 1, num_attackers do
		local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(i);
		
		if Is_Bretonnian(attacker_name) then
			table.insert(bret_attackers, attacker_name);
		end
	end

	for i = 1, num_defenders do
		local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(i);
		
		if Is_Bretonnian(defender_name) then
			table.insert(bret_defenders, defender_name);
		end
	end
	
	---------------------------------------------------
	---- GIVE CHIVALRY TO ALL RELEVANT BRETONNIANS ----
	---------------------------------------------------
	local primary_attacker_cqi, primary_attacker_force_cqi, primary_attacker_name = cm:pending_battle_cache_get_attacker(1);
	local primary_defender_cqi, primary_defender_force_cqi, primary_defender_name = cm:pending_battle_cache_get_defender(1);
	local primary_attacker = cm:model():world():faction_by_key(primary_attacker_name);
	local primary_defender = cm:model():world():faction_by_key(primary_defender_name);
	
	local attacker_result = cm:model():pending_battle():attacker_battle_result();
	local defender_result = cm:model():pending_battle():defender_battle_result();
	
	for i = 1, #bret_attackers do
		local attacker = cm:model():world():faction_by_key(bret_attackers[i]);
	
		if attacker:is_null_interface() == false and attacker:is_dead() == false then
			local attacker_name = attacker:name();
			out("\tAttacker: "..attacker_name);
			local chivalry_value = CHIVALRY_BATTLE_RESULT_VALUES[attacker_result];
			out("\tChivalry Reward: "..tostring(chivalry_value));
			
			local chivalry_bonus = 0;
			if primary_defender:is_null_interface() == false then
				chivalry_bonus = GetChivalryTechBonusForFaction(attacker_name, primary_defender:subculture());
			end
			out("\tBonus Chivalry: "..chivalry_bonus);
			
			if chivalry_value ~= nil then
				out("\tChivalry Factor: "..CHIVALRY_BATTLE_FACTOR..attacker_result);
			
				local current = attacker:get_food_factor_value(CHIVALRY_BATTLE_FACTOR..attacker_result);
				out("\tCurrent Chivalry: "..current);
				
				if chivalry_value > 0 then
					current = current + chivalry_value + chivalry_bonus;
					out("\tNew Chivalry: "..current);
					cm:faction_set_food_factor_value(attacker_name, CHIVALRY_BATTLE_FACTOR..attacker_result, current);
				else
					current = current + chivalry_value;
					out("\tNew Chivalry: "..current);
					cm:faction_set_food_factor_value(attacker_name, CHIVALRY_BATTLE_FACTOR..attacker_result, current);
				end
			end
			
			Check_Chivalry_Win_Condition(attacker);
			
			remove_occupation_effect_bundles(attacker_name, true, true);
		end
	end
	
	for i = 1, #bret_defenders do
		local defender = cm:model():world():faction_by_key(bret_defenders[i]);
	
		if defender:is_null_interface() == false and defender:is_dead() == false then
			local defender_name = defender:name();
			out("\tDefender: "..defender_name);
			local chivalry_value = CHIVALRY_BATTLE_RESULT_VALUES[defender_result];
			out("\tChivalry Reward: "..tostring(chivalry_value));
			
			local chivalry_bonus = 0;
			if primary_attacker:is_null_interface() == false then
				chivalry_bonus = GetChivalryTechBonusForFaction(defender_name, primary_attacker:subculture());
			end
			out("\tBonus Chivalry: "..chivalry_bonus);
			
			if chivalry_value ~= nil then
				out("\tChivalry Factor: "..CHIVALRY_BATTLE_FACTOR..defender_result);
				
				local current = defender:get_food_factor_value(CHIVALRY_BATTLE_FACTOR..defender_result);
				out("\tCurrent Chivalry: "..current);
				
				if chivalry_value > 0 then
					current = current + chivalry_value + chivalry_bonus;
					out("\tNew Chivalry: "..current);
					cm:faction_set_food_factor_value(defender_name, CHIVALRY_BATTLE_FACTOR..defender_result, current);
				else
					current = current + chivalry_value;
					out("\tNew Chivalry: "..current);
					cm:faction_set_food_factor_value(defender_name, CHIVALRY_BATTLE_FACTOR..defender_result, current);
				end
			end
			
			Check_Chivalry_Win_Condition(defender);
			
			remove_occupation_effect_bundles(defender_name, true, true);
		end
	end
end

-- TRAITS
function Bret_ChivalryFactionTurnStart(context)
	CalculateChivalryTraitsForFaction(context:faction());
end
function Bret_ChivalryMilitaryForceCreated(context)
	CalculateChivalryTraitsForFaction(context:military_force_created():faction());
end

function CalculateChivalryTraitsForFaction(faction)
	if Is_Bretonnian(faction:name()) then
		local trait_value_positive = 0;
		local trait_value_negative = 0;
		local characters = faction:character_list();

		for i = 0, characters:num_items() - 1 do
			local current_char = characters:item_at(i);

			if current_char:character_type("colonel") == false then
				-- Traits
				for key, trait in pairs(CHIVALRY_TRAITS) do
					local trait_points = current_char:trait_points(key);
					
					if trait_points > 0 then
						-- Iterate backwards (highest trait level first)
						for j = #trait.levels, 1, -1 do
							local trait_level = trait.levels[j];
							
							if trait_points >= trait_level.points then
								local chivalry_value = trait_level.chivalry;
								
								if chivalry_value > 0 then
									trait_value_positive = trait_value_positive + chivalry_value;
								elseif chivalry_value < 0 then
									trait_value_negative = trait_value_negative + chivalry_value;
								end
								break;
							end
						end
					end
				end
				
				-- Skills
				for j = 1, #CHIVALRY_SKILLS do
					if current_char:has_skill(CHIVALRY_SKILLS[j].skill) then
						local val = CHIVALRY_SKILLS[j].value;
						
						if val > 0 then
							trait_value_positive = trait_value_positive + val;
						elseif val < 0 then
							trait_value_negative = trait_value_negative + val;
						end
					end
				end
			end
		end
		
		cm:faction_set_food_factor_value(faction:name(), CHIVALRY_GOOD_TRAIT_FACTOR, trait_value_positive);
		cm:faction_set_food_factor_value(faction:name(), CHIVALRY_BAD_TRAIT_FACTOR, trait_value_negative);
		Check_Chivalry_Win_Condition(faction);
	end
end

-- RAIDING / AMBUSHING
function Bret_CharacterTurnEnd(context)
	local character = context:character();
	local faction = character:faction();

	if Is_Bretonnian(faction:name()) then
		if character:has_military_force() == true then
			local military_force = character:military_force();

			if military_force:active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_LAND_RAID" then
				-- Raiding
				local current = faction:get_food_factor_value(CHIVALRY_RAIDING_FACTOR);
				cm:faction_set_food_factor_value(faction:name(), CHIVALRY_RAIDING_FACTOR, current + CHIVALRY_RAIDING_VALUE);
			elseif military_force:active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_AMBUSH" then
				-- Ambushing
				local current = faction:get_food_factor_value(CHIVALRY_AMBUSHING_FACTOR);
				cm:faction_set_food_factor_value(faction:name(), CHIVALRY_AMBUSHING_FACTOR, current + CHIVALRY_AMBUSHING_VALUE);
			end
		end
	end
end

-- RANSOMING
function Bret_CharacterPostBattleRelease(context)
	if Is_Bretonnian(context:character():faction():name()) then
		local current = context:character():faction():get_food_factor_value(CHIVALRY_RANSOM_FACTOR);
		cm:faction_set_food_factor_value(context:character():faction():name(), CHIVALRY_RANSOM_FACTOR, current + CHIVARLY_RANSOM_VALUE);
		cm:remove_effect_bundle_from_characters_force("wh_main_bundle_captives_release_bretonnia", context:character():cqi());
	end
end

-- SACKING
function Bret_CharacterSackedSettlement(context)
	if Is_Bretonnian(context:character():faction():name()) then
		local current = context:character():faction():get_food_factor_value(CHIVALRY_SACKING_FACTOR);
		local faction_name = context:character():faction():name();
		cm:faction_set_food_factor_value(faction_name, CHIVALRY_SACKING_FACTOR, current + CHIVALRY_SACKING_VALUE);
		
		cm:callback(
			function()
				remove_occupation_effect_bundles(faction_name, true, false);
			end,
			0.5
		);
	end
end

-- RAZING
function Bret_CharacterRazedSettlement(context)
	local faction_name = context:character():faction():name();
	
	if Is_Bretonnian(faction_name) then
		local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(1);
		
		if defender_name ~= "rebels" then
			if CHIVALRY_LAST_ATTACKED_GARRISON ~= "" and (CHIVALRY_LAST_ATTACKED_GARRISON ~= defender_name) then
				-- If we get here we can assume there was no garrison as the last battle faction differs from the last attacked garrison owner
				defender_name = CHIVALRY_LAST_ATTACKED_GARRISON;
			end
			
			local razed_faction = cm:model():world():faction_by_key(defender_name);
			
			if razed_faction:is_null_interface() == false then
				local razed_sc = razed_faction:subculture();
				
				if razed_sc == "wh_main_sc_grn_greenskins" or razed_sc == "wh_main_sc_vmp_vampire_counts" or razed_sc == "wh_main_sc_nor_norsca" or razed_sc == "wh_main_sc_grn_savage_orcs" or razed_sc == "wh2_dlc09_sc_tmb_tomb_kings" or razed_sc == "wh2_dlc11_sc_cst_vampire_coast" then
					-- Razed a bad guy!
					local current = context:character():faction():get_food_factor_value(CHIVALRY_RAZING_FACTOR);
					cm:faction_set_food_factor_value(faction_name, CHIVALRY_RAZING_FACTOR, current + CHIVALRY_RAZING_VALUE_ENEMY);
					Check_Chivalry_Win_Condition(context:character():faction());
				elseif razed_sc == "wh_main_sc_brt_bretonnia" or razed_sc == "wh_main_sc_emp_empire" or razed_sc == "wh_main_sc_ksl_kislev" or razed_sc == "wh_main_sc_teb_teb" then
					-- Razed a human!
					local current = context:character():faction():get_food_factor_value(CHIVALRY_RAZING_FACTOR.."_humans");
					cm:faction_set_food_factor_value(faction_name, CHIVALRY_RAZING_FACTOR.."_humans", current + CHIVALRY_RAZING_VALUE_HUMANS);
				end
			end
		end
		
		cm:callback(
			function()
				remove_occupation_effect_bundles(faction_name, false, true);
			end,
			0.5
		);
	end
end

-- INCIDENTS
function Bret_IncidentOccuredEvent(context)
	if Is_Bretonnian(context:faction():name()) then
		local value = CHIVALRY_EVENT_PAYLOADS["incidents"][context:dilemma()];
		
		if value ~= nil and is_number(value) then
			local current = context:faction():get_food_factor_value(CHIVALRY_EVENT_FACTOR);
			out("CHIVALRY INCIDENT - "..context:dilemma()..": "..current.." + "..value.." = "..(current + value));
			cm:faction_set_food_factor_value(context:faction():name(), CHIVALRY_EVENT_FACTOR, current + value);
			Check_Chivalry_Win_Condition(context:faction());
		end
	end
end

-- DILEMMAS
function Bret_ChivalryDilemmaChoiceMadeEvent(context)
	if Is_Bretonnian(context:faction():name()) then
		local choice = context:choice() + 1;
		local tab = CHIVALRY_EVENT_PAYLOADS["dilemmas"][context:dilemma()];
		
		if tab ~= nil then
			local value = tab[choice];
			
			if value ~= nil and is_number(value) then
				local current = context:faction():get_food_factor_value(CHIVALRY_EVENT_FACTOR);
				out("CHIVALRY DILEMMA - "..context:dilemma().."("..choice.."): "..current.." + "..value.." = "..(current + value));
				cm:faction_set_food_factor_value(context:faction():name(), CHIVALRY_EVENT_FACTOR, current + value);
			end
		end
	end
end

-- QUESTS
function Bret_Quests_MissionSucceeded(context)
	if Is_Bretonnian(context:faction():name()) then
		local chivalry_value = CHIVALRY_QUESTS[context:mission():mission_record_key()] or 0;
		
		if chivalry_value > 0 then
			local current = context:faction():get_food_factor_value(CHIVALRY_EVENT_FACTOR);
			cm:faction_set_food_factor_value(context:faction():name(), CHIVALRY_EVENT_FACTOR, current + chivalry_value);
			Check_Chivalry_Win_Condition(context:faction());
		end
	end
end

-- DECLARING WAR
function Bret_NegativeDiplomaticEvent(context)
	if context:proposer():subculture() == "wh_main_sc_brt_bretonnia" and context:recipient():subculture() == "wh_main_sc_brt_bretonnia" then
		if context:is_war() == true and context:proposer():is_human() == true then
			local current = context:proposer():get_food_factor_value(CHIVALRY_BRETONNIAN_WAR_FACTOR);
			out("BRETONNIAN WAR ("..context:proposer():name().." vs "..context:recipient():name()..") - "..current.." + "..CHIVALRY_BRETONNIAN_WAR_VALUE.." = "..(current + CHIVALRY_BRETONNIAN_WAR_VALUE));
			cm:faction_set_food_factor_value(context:proposer():name(), CHIVALRY_BRETONNIAN_WAR_FACTOR, current + CHIVALRY_BRETONNIAN_WAR_VALUE);
		end
	end
end

function Bret_ChivalryVariationMonitor(context)
	if context:faction():subculture() == "wh_main_sc_brt_bretonnia" then
		local fac_name = context:faction():name();
		local previous_food = cm:get_saved_value("ScriptPreviousFoodValue_"..fac_name);
		local current_food = context:faction():total_food();
		
		if previous_food ~= nil then
			if current_food > previous_food then
				core:trigger_event("ScriptEventFoodValueUp");
			elseif current_food < previous_food then
				core:trigger_event("ScriptEventFoodValueDown");
			end
		else 
			previous_food = 0;
		end
		for i = 1, #CHIVALRY_THRESHOLDS do
			if previous_food < CHIVALRY_THRESHOLDS[i] and current_food >= CHIVALRY_THRESHOLDS[i] then
				core:trigger_event("ScriptEventFoodLevelUp");
			elseif previous_food > CHIVALRY_THRESHOLDS[i] and current_food <= CHIVALRY_THRESHOLDS[i] then
				core:trigger_event("ScriptEventFoodLevelDown");
			end
		end
		cm:set_saved_value("ScriptPreviousFoodValue_"..fac_name, context:faction():total_food());
	end
end

function GetChivalryTechBonusForFaction(faction_key, fighting_subculture)
	local faction = cm:model():world():faction_by_key(faction_key);
	local bonus_val = 0;
	
	if faction:is_null_interface() == false then
		if fighting_subculture == "wh_main_sc_grn_greenskins" or fighting_subculture == "wh_main_sc_grn_savage_orcs" then
			if faction:has_technology("tech_dlc07_brt_chivalry_greenskins_1") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_greenskins_1"] or 0;
			end;
			
			if faction:has_technology("tech_dlc07_brt_chivalry_greenskins_2") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_greenskins_2"] or 0;
			end
		elseif fighting_subculture == "wh_dlc03_sc_bst_beastmen" then
			if faction:has_technology("tech_dlc07_brt_chivalry_beastmen_1") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_beastmen_1"] or 0;
			end
		elseif fighting_subculture == "wh_main_sc_chs_chaos" then
			if faction:has_technology("tech_dlc07_brt_chivalry_chaos_1") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_chaos_1"] or 0;
			end
		elseif fighting_subculture == "wh_main_sc_nor_norsca" then
			if faction:has_technology("tech_dlc07_brt_chivalry_norsca_1") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_norsca_1"] or 0;
			elseif faction:has_technology("tech_dlc07_brt_chivalry_norsca_2") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_norsca_2"] or 0;
			end
		elseif fighting_subculture == "wh_main_sc_vmp_vampire_counts" then
			if faction:has_technology("tech_dlc07_brt_chivalry_vampires_1") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_vampires_1"] or 0;
			end
		elseif fighting_subculture == "wh_dlc05_sc_wef_wood_elves" then
			if faction:has_technology("tech_dlc07_brt_chivalry_wood_elves_1") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_wood_elves_1"] or 0;
			end
		elseif fighting_subculture == "wh2_main_sc_def_dark_elves" then
			if faction:has_technology("tech_dlc07_brt_chivalry_dark_elves_1") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_dark_elves_1"] or 0;
			end
		elseif fighting_subculture == "wh2_main_sc_skv_skaven" then
			if faction:has_technology("tech_dlc07_brt_chivalry_skaven") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_skaven_1"] or 0;
			end
		elseif fighting_subculture == "wh2_dlc09_sc_tmb_tomb_kings" then
			if faction:has_technology("tech_dlc07_brt_chivalry_tomb_kings") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc07_brt_chivalry_tomb_kings_1"] or 0;
			end
		elseif fighting_subculture == "wh2_dlc11_sc_cst_vampire_coast" then
			if faction:has_technology("tech_dlc11_brt_chivalry_vampire_coast_1") then
				bonus_val = bonus_val + CHIVALRY_TECH_BONUSES["tech_dlc11_brt_chivalry_vampire_coast_1"] or 0;
			end
		end
	end
	return bonus_val;
end

function remove_occupation_effect_bundles(faction_name, sacking, razing)
	local faction = cm:get_faction(faction_name);
	
	local function remove_bundles(bundles)
		for i = 1, #bundles do
			local current_bundle = bundles[i];
			
			if faction:has_effect_bundle(current_bundle) then
				cm:remove_effect_bundle(current_bundle, faction_name);
			end;
		end;
	end;
	
	if sacking then
		remove_bundles(
			{
				"wh_dlc07_occupation_bretonnia_chivalry_dummy_sacking_humans",
				"wh_dlc07_occupation_bretonnia_chivalry_dummy_sacking_enemy",
				"wh_dlc07_occupation_bretonnia_chivalry_dummy_sacking_neutral"
			}
		);
	end;
	
	if razing then
		remove_bundles(
			{
				"wh_dlc07_occupation_bretonnia_chivalry_dummy_razing_humans",
				"wh_dlc07_occupation_bretonnia_chivalry_dummy_razing_enemy"
			}
		);
	end;
end;
ENABLE_GOD_BAR_DEBUG = false;

NORSCAN_REWARD_LORD_OF_CHANGE = {["wh_dlc08_nor_norsca"] = "1007509378", ["wh_dlc08_nor_wintertooth"] = "2107575863"};
NORSCAN_REWARD_SUPER_AGENT = "dlc08_nor_kihar";
NORSCAN_REWARD_HELL_CANNON = "wh_dlc08_nor_art_hellcannon_battery";

NORSCAN_GODS = {
	--[[
	["wh_dlc08_nor_norsca"] = {
		["khorne"] = {favour = 0, aligned = false, spawned = false, defeated = false, final = false, challenger_cqi = -1, challenger_force_cqi = -1}
	}
	]]--
};

NORSCAN_FAVOUR_GAIN = 6;
NORSCAN_FAVOUR_LOSS = -2;
MAX_NORSCAN_GOD_FAVOUR = 100;
CHAPTER_1_FAVOUR_REQUIREMENT = 30;
CHAPTER_2_FAVOUR_REQUIREMENT = 60;
CHAPTER_3_FAVOUR_REQUIREMENT = 100;
NORSCAN_CHALLENGER_FACTION_PREFIX = "wh_dlc08_chs_chaos_challenger_";

NORSCA_SPAWN_LOCATIONS = {};

GOD_KEY_TO_UI_KEY = {
	["khorne"] = "hound",
	["slaanesh"] = "serpent",
	["nurgle"] = "crow",
	["tzeentch"] = "eagle"
};

RAZE_ID_TO_GOD_KEY = {
	["1963655228"] = "khorne",
	["1824195232"] = "slaanesh",
	["1369123792"] = "nurgle",
	["1292694896"] = "tzeentch"
};

GOD_KEY_TO_CHALLENGER_DETAILS = {
	["khorne"] = {make_faction_leader = true, agent_subtype = "wh_dlc08_chs_challenger_khorne", forename = "names_name_635561999", clan_name = "", family_name = "", other_name = "", effect_bundle = "wh_main_bundle_military_upkeep_free_force_special_character_unbreakable"},
	["slaanesh"] = {make_faction_leader = true, agent_subtype = "wh_dlc08_chs_challenger_slaanesh", forename = "names_name_1572470675", clan_name = "", family_name = "", other_name = "", effect_bundle = "wh_main_bundle_military_upkeep_free_force_special_character_unbreakable"},
	["nurgle"] = {make_faction_leader = true, agent_subtype = "wh_dlc08_chs_challenger_nurgle", forename = "names_name_327875186", clan_name = "", family_name = "", other_name = "", effect_bundle = "wh_main_bundle_military_upkeep_free_force_special_character_unbreakable"},
	["tzeentch"] = {make_faction_leader = true, agent_subtype = "wh_dlc08_nor_arzik", forename = "names_name_1019189048", clan_name = "", family_name = "", other_name = "", effect_bundle = "wh_main_bundle_military_upkeep_free_force_special_character_unbreakable"}
};

CHAOS_CHALLENGER_FACTION_KEY_LOOKUP = {
	["wh_dlc08_chs_chaos_challenger_khorne"] = true,
	["wh_dlc08_chs_chaos_challenger_nurgle"] = true,
	["wh_dlc08_chs_chaos_challenger_slaanesh"] = true,
	["wh_dlc08_chs_chaos_challenger_tzeentch"] = true
};

DILEMMA_TO_GOD_EFFECTS = {
	["wh_dlc08_nor_monster_hunt_0_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh_dlc08_nor_monster_hunt_1_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh_dlc08_nor_monster_hunt_2_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh_dlc08_nor_monster_hunt_3_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh_dlc08_nor_monster_hunt_4_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh_dlc08_nor_monster_hunt_5_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh_dlc08_nor_monster_hunt_6_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh_dlc08_nor_monster_hunt_7_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh2_dlc10_nor_monster_hunt_8_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh2_dlc10_nor_monster_hunt_9_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh2_dlc10_nor_monster_hunt_10_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	},
	["wh2_dlc10_nor_monster_hunt_11_dilemma_reward"] = {
		["0"] = {
			god_key = "nurgle",
			gain = 12,
			loss = -4
		},
		["1"] = {
			god_key = "tzeentch",
			gain = 12,
			loss = -4
		},
		["2"] = {
			god_key = "khorne",
			gain = 12,
			loss = -4
		},
		["3"] = {
			god_key = "slaanesh",
			gain = 12,
			loss = -4
		}
	}
};

function Add_Norscan_Gods_Listeners()
	out("#### Adding Norscan Gods Listeners ####");
	core:add_listener(
		"Norsca_CharacterPerformsSettlementOccupationDecision",
		"CharacterPerformsSettlementOccupationDecision",
		true,
		function(context) Norsca_CharacterPerformsSettlementOccupationDecision(context) end,
		true
	);
	core:add_listener(
		"Norsca_DilemmaChoiceMadeEvent",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) Nosrca_DilemmaChoiceMadeEvent(context) end,
		true
	);
	core:add_listener(
		"Norsca_UniqueAgentSpawned",
		"UniqueAgentSpawned",
		true,
		function(context) Norsca_UniqueAgentSpawned(context) end,
		true
	);
	for norsca_challenger_faction_name in pairs(CHAOS_CHALLENGER_FACTION_KEY_LOOKUP) do
		cm:add_faction_turn_start_listener_by_name(
			"Norsca_ChallengerTurnStart",
			norsca_challenger_faction_name,
			Norsca_ChallengerTurnStart,
			true
		);
	end;
	core:add_listener(
		"Norsca_CharacterCreated",
		"CharacterCreated",
		true,
		function(context) Norsca_CharacterCreated(context) end,
		true
	);
	core:add_listener(
		"Norsca_ComponentLClickUp",
		"ComponentLClickUp", 
		true,
		function(context) Norsca_ComponentLClickUp(context) end, 
		true
	);
	
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		
		if faction:is_null_interface() == false and faction:is_human() == true and faction:subculture() == "wh_main_sc_nor_norsca" then
			local faction_key = faction:name();
			out("\t\t"..faction:name()..":");
			
			if cm:is_new_game() == false then
				if NORSCAN_GODS[faction_key] ~= nil then
					UpdateNorscanGodEffects(faction_key);
					UpdateNorscanGodUI(faction_key);
				end
			else
				NORSCAN_GODS[faction_key] = NORSCAN_GODS[faction_key] or {};
				
				for raze_id, god_key in pairs(RAZE_ID_TO_GOD_KEY) do
					NORSCAN_GODS[faction_key][god_key] = NORSCAN_GODS[faction_key][god_key] or {};
					NORSCAN_GODS[faction_key][god_key].favour = NORSCAN_GODS[faction_key][god_key].favour or 0;
					NORSCAN_GODS[faction_key][god_key].aligned = NORSCAN_GODS[faction_key][god_key].aligned or false;
					NORSCAN_GODS[faction_key][god_key].spawned = NORSCAN_GODS[faction_key][god_key].spawned or false;
					NORSCAN_GODS[faction_key][god_key].defeated = NORSCAN_GODS[faction_key][god_key].defeated or false;
					NORSCAN_GODS[faction_key][god_key].final = NORSCAN_GODS[faction_key][god_key].final or false;
					NORSCAN_GODS[faction_key][god_key].challenger_cqi = NORSCAN_GODS[faction_key][god_key].challenger_cqi or -1;
					NORSCAN_GODS[faction_key][god_key].challenger_force_cqi = NORSCAN_GODS[faction_key][god_key].challenger_force_cqi or -1;
					NORSCAN_GODS[faction_key][god_key].mission_record = NORSCAN_GODS[faction_key][god_key].mission_record or "";
					out("\t\t\t"..tostring(god_key)..": "..tostring(NORSCAN_GODS[faction_key][god_key].favour));
				end
			end
		end
	end
	
	-- Uses random army manager
	Setup_Challenger_Armies();
	
	-- Remove the challenger armies
	if ((cm:is_new_game() == true) and (cm:get_campaign_name() == "main_warhammer")) then
		-- Challenger spawn locations
		table.insert(NORSCA_SPAWN_LOCATIONS, {776, 598});
		table.insert(NORSCA_SPAWN_LOCATIONS, {609, 690});
		table.insert(NORSCA_SPAWN_LOCATIONS, {538, 701});
		table.insert(NORSCA_SPAWN_LOCATIONS, {368, 634});
	
		Remove_Norscan_Challengers();
		
		cm:lock_starting_general_recruitment(NORSCAN_REWARD_LORD_OF_CHANGE["wh_dlc08_nor_norsca"], "wh_dlc08_nor_norsca");
		cm:lock_starting_general_recruitment(NORSCAN_REWARD_LORD_OF_CHANGE["wh_dlc08_nor_wintertooth"], "wh_dlc08_nor_wintertooth");
		
		cm:add_event_restricted_unit_record_for_faction(NORSCAN_REWARD_HELL_CANNON, "wh_dlc08_nor_norsca", "norsca_ror_unlock_reason");
		cm:add_event_restricted_unit_record_for_faction(NORSCAN_REWARD_HELL_CANNON, "wh_dlc08_nor_wintertooth", "norsca_ror_unlock_reason");
		-- Norsca Monster Hunt Rewards
		cm:add_event_restricted_unit_record_for_faction("wh_dlc08_nor_mon_war_mammoth_ror_1", "wh_dlc08_nor_norsca", "norsca_monster_hunt_ror_unlock");
		cm:add_event_restricted_unit_record_for_faction("wh_dlc08_nor_mon_war_mammoth_ror_1", "wh_dlc08_nor_wintertooth", "norsca_monster_hunt_ror_unlock");
		cm:add_event_restricted_unit_record_for_faction("wh_dlc08_nor_mon_frost_wyrm_ror_0", "wh_dlc08_nor_norsca", "norsca_monster_hunt_ror_unlock");
		cm:add_event_restricted_unit_record_for_faction("wh_dlc08_nor_mon_frost_wyrm_ror_0", "wh_dlc08_nor_wintertooth", "norsca_monster_hunt_ror_unlock");
	
		NorscaChallengersSpawned:start();
	end
	
	if ENABLE_GOD_BAR_DEBUG == true then
		out("\n\n\t!!!! WARNING !!!!\n\t\tENABLE_GOD_BAR_DEBUG is true!\n\t!!!! WARNING !!!!\n");
	end
end

function Norsca_ComponentLClickUp(context)
	if ENABLE_GOD_BAR_DEBUG == true then
		local fac = cm:model():world():whose_turn_is_it():name();
		local clicked_level = 0;
		local god = "";
		
		if UIComponent(context.component):Id() == "level_3" then
			clicked_level = 3;
		elseif UIComponent(context.component):Id() == "level_2" then
			clicked_level = 2;
		elseif UIComponent(context.component):Id() == "level_1" then
			clicked_level = 1;
		end
		
		if clicked_level > 0 then
			if UIComponent(UIComponent(context.component):Parent()):Id() == "list_hound" then
				god = "khorne";
			elseif UIComponent(UIComponent(context.component):Parent()):Id() == "list_eagle" then
				god = "tzeentch";
			elseif UIComponent(UIComponent(context.component):Parent()):Id() == "list_crow" then
				god = "nurgle";
			elseif UIComponent(UIComponent(context.component):Parent()):Id() == "list_serpent" then
				god = "slaanesh";
			end
		
			if god ~= "" then
				if NORSCAN_GODS[fac] ~= nil then
					if NORSCAN_GODS[fac][god] ~= nil then
						local fav = NORSCAN_GODS[fac][god].favour;
						
						if clicked_level == 1 then
							Add_God_Favour(fac, god, -10, 0);
						elseif clicked_level == 3 then
							Add_God_Favour(fac, god, 10, 0);
						end
					end
				end
			end
		end
	end
end

function Add_God_Favour(faction_key, god_key, amount, amount_others)
	out("Add_God_Favour("..faction_key..", "..god_key..", "..amount..", "..amount_others..")");
	Play_Norsca_Advice("dlc08.camp.advice.nor.gods.002", norsca_info_text_gods);
	
	local arrow_tab = {};
	
	for key, data in pairs(NORSCAN_GODS[faction_key]) do
		local current_favour = data.favour or 0;
		
		if current_favour >= MAX_NORSCAN_GOD_FAVOUR then
			-- Already won
			return false;
		end
		
		if key == god_key then
			-- This is the god!
			current_favour = current_favour + amount;
			
			if amount > 0 then
				arrow_tab[key] = "arrow_up";
			elseif amount < 0 then
				arrow_tab[key] = "arrow_down";
			end
		else
			-- This is another god!
			current_favour = current_favour + amount_others;
			
			if amount_others > 0 then
				arrow_tab[key] = "arrow_up";
			elseif amount_others < 0 then
				arrow_tab[key] = "arrow_down";
			end
		end
		
		-- Clamp favour
		if current_favour < 0 then
			current_favour = 0;
		elseif current_favour > MAX_NORSCAN_GOD_FAVOUR then
			current_favour = MAX_NORSCAN_GOD_FAVOUR;
		end
		
		data.favour = current_favour;
		local win = Check_God_Favour_Win_Conditions(faction_key, key);
		
		if win == true then
			-- If we've completed the objective then we no longer need to check others
			break;
		end
	end
	
	UpdateNorscanGodEffects(faction_key);
	UpdateNorscanGodUI(faction_key, arrow_tab);
	return true;
end

function Check_God_Favour_Win_Conditions(faction_key, god_key)
	local current_favour = NORSCAN_GODS[faction_key][god_key].favour;

	if current_favour >= CHAPTER_3_FAVOUR_REQUIREMENT then
		cm:complete_scripted_mission_objective("wh_dlc08_objective_03_"..faction_key, "gain_chapter_favour_"..faction_key, true);
		Give_Final_God_Reward(faction_key, god_key);
	end
	if current_favour >= CHAPTER_2_FAVOUR_REQUIREMENT then
		cm:complete_scripted_mission_objective("wh_dlc08_objective_02_"..faction_key, "gain_chapter_favour_"..faction_key, true);
	end
	if current_favour >= CHAPTER_1_FAVOUR_REQUIREMENT then
		cm:complete_scripted_mission_objective("wh_dlc08_objective_01_"..faction_key, "gain_chapter_favour_"..faction_key, true);
	end
	if current_favour >= MAX_NORSCAN_GOD_FAVOUR then
		Trigger_God_Challengers(faction_key, god_key);
		return true;
	end
	return false;
end

function UpdateNorscanGodEffects(faction_key)
	if NORSCAN_GODS[faction_key] ~= nil then
		for key, data in pairs(NORSCAN_GODS[faction_key]) do
			cm:remove_effect_bundle("wh_dlc08_bundle_god_bar_"..key.."_1", faction_key);
			cm:remove_effect_bundle("wh_dlc08_bundle_god_bar_"..key.."_2", faction_key);
			cm:remove_effect_bundle("wh_dlc08_bundle_god_bar_"..key.."_3", faction_key);
			
			if data.favour >= CHAPTER_3_FAVOUR_REQUIREMENT then
				cm:apply_effect_bundle("wh_dlc08_bundle_god_bar_"..key.."_3", faction_key, 0);
				--Play_Norsca_Advice("dlc08.camp.advice.nor.gods_"..key..".003", norsca_info_text_gods); -- Deal with this advice in the challenger cutscene
			elseif data.favour >= CHAPTER_2_FAVOUR_REQUIREMENT then
				cm:apply_effect_bundle("wh_dlc08_bundle_god_bar_"..key.."_2", faction_key, 0);
				Play_Norsca_Advice("dlc08.camp.advice.nor.gods_"..key..".002", norsca_info_text_gods);
			elseif data.favour >= CHAPTER_1_FAVOUR_REQUIREMENT then
				cm:apply_effect_bundle("wh_dlc08_bundle_god_bar_"..key.."_1", faction_key, 0);
				Play_Norsca_Advice("dlc08.camp.advice.nor.gods_"..key..".001", norsca_info_text_gods);
			end
			
			if data.favour >= (CHAPTER_3_FAVOUR_REQUIREMENT - NORSCAN_FAVOUR_GAIN) and data.favour < CHAPTER_3_FAVOUR_REQUIREMENT then
				if NORSCA_ADVICE["dlc08.camp.advice.nor.gods_"..key..".002"] == true then
					Play_Norsca_Advice("dlc08.camp.advice.nor.gods.004", norsca_info_text_gods);
				end
			end
		end
	end
end

function UpdateNorscanGodUI(faction_key, arrow_tab)
	if NORSCAN_GODS[faction_key] ~= nil then
		local local_faction = cm:get_local_faction_name(true);
		
		if local_faction == faction_key then
			local norsca_favour_uic = find_uicomponent(core:get_ui_root(), "norsca_favour");
			
			if norsca_favour_uic ~= nil then
				local khorne = 0;
				local slaanesh = 0;
				local nurgle = 0;
				local tzeentch = 0;
				
				for key, data in pairs(NORSCAN_GODS[faction_key]) do
					if key == "khorne" then
						khorne = data.favour;
					elseif key == "slaanesh" then
						slaanesh = data.favour;
					elseif key == "nurgle" then
						nurgle = data.favour;
					elseif key == "tzeentch" then
						tzeentch = data.favour;
					end
				end
				
				out("UpdateNorscanGodUI - "..faction_key.."\n\tKhorne: "..khorne.."\n\tSlaanesh: "..slaanesh.."\n\tNurgle: "..nurgle.."\n\tTzeentch: "..tzeentch);
				norsca_favour_uic:InterfaceFunction("SetValues", faction_key, khorne, slaanesh, nurgle, tzeentch);
				
				if arrow_tab ~= nil then
					for key, arrow in pairs(arrow_tab) do
						norsca_favour_uic:InterfaceFunction("PlayAnimation", faction_key, GOD_KEY_TO_UI_KEY[key], arrow);
					end
				end
			else
				script_error("ERROR: Couldn't locate the norsca_favour_uic UI component!");
			end
		end
	end
end

function Norsca_CharacterPerformsSettlementOccupationDecision(context)
	local character = context:character();
	
	if character:is_null_interface() == false then
		if character:faction():is_human() == true then
			if character:faction():subculture() == "wh_main_sc_nor_norsca" then
				out("Norsca_CharacterPerformsSettlementOccupationDecision - ");
				local occupation_decision = context:occupation_decision();
				out("\toccupation_decision - "..occupation_decision);
				
				-- Determine what god is associated with the raze option
				local god_key = RAZE_ID_TO_GOD_KEY[occupation_decision];
				out("\tRAZE_ID_TO_GOD_KEY - "..tostring(god_key));
				
				if god_key ~= nil then
					local god_selected = Has_Aligned_With_God(character:faction():name());
					
					-- Make sure the player hasn't already achieved maximum favour
					if god_selected == false then
						Add_God_Favour(character:faction():name(), god_key, NORSCAN_FAVOUR_GAIN, NORSCAN_FAVOUR_LOSS);
					end
				end
			end
		end
	end
end

function Trigger_God_Challengers(faction_key, god_key)
	if Has_Aligned_With_God(faction_key) then
		return false;
	end

	local lowest_god = god_key;
	local lowest_value = 999999;

	for key, data in pairs(NORSCAN_GODS[faction_key]) do
		if key == god_key then
			-- This is your chosen god!
			data.aligned = true;
		else
			-- This is an enemy god!
			data.aligned = false;
			
			if data.favour <= lowest_value then
				lowest_god = key;
				lowest_value = data.favour;
			end
		end
	end
	
	-- The God with the worst relation becomes the final quest battle
	NORSCAN_GODS[faction_key][lowest_god].final = true;
	
	for key, data in pairs(NORSCAN_GODS[faction_key]) do
		out("God - "..key);
		out("\tFavour - "..tostring(data.favour));
		out("\tAligned - "..tostring(data.aligned));
		out("\tFinal - "..tostring(data.final));
	end
	
	local wars_to_do = {};
	local challengers_spawned = {};
	local missions_to_spawn = {};
	local is_mp = cm:is_multiplayer();
	
	if #NORSCA_SPAWN_LOCATIONS < 1 then
		out("There were no Norsca spawn locations?! Adding some...");
		table.insert(NORSCA_SPAWN_LOCATIONS, {776, 598});
		table.insert(NORSCA_SPAWN_LOCATIONS, {609, 690});
		table.insert(NORSCA_SPAWN_LOCATIONS, {538, 701});
		table.insert(NORSCA_SPAWN_LOCATIONS, {368, 634});
	end
	
	for key, data in pairs(NORSCAN_GODS[faction_key]) do
		if data.aligned == false then
			if data.final == false then
				out("\n#######################################################\n Spawn_Challenger("..faction_key..", "..key..", "..tostring(is_mp)..")\n#######################################################\n");
				local spawn_pos, mission_key = Spawn_Challenger(faction_key, key, is_mp);
				table.insert(wars_to_do, key);
				table.insert(challengers_spawned, spawn_pos);
				table.insert(missions_to_spawn, mission_key);
				data.spawned = true;
			end
		end
	end
	
	out("MP Challenger missions to spawn: "..#missions_to_spawn);
	
	if is_mp == true then
		cm:force_declare_war(NORSCAN_CHALLENGER_FACTION_PREFIX..wars_to_do[1], faction_key, false, false);
		
		core:add_listener(
			"Norsca_FactionLeaderDeclaresWar",
			"FactionLeaderDeclaresWar",
			function(context) return context:character():faction():name() == NORSCAN_CHALLENGER_FACTION_PREFIX..wars_to_do[1] end,
			function(context)
				cm:force_declare_war(NORSCAN_CHALLENGER_FACTION_PREFIX..wars_to_do[2], faction_key, false, false);
			end,
			false
		);
	end
	
	if #challengers_spawned > 0 then
		if cm:is_multiplayer() == false then
			out("++++ TRIGGER: ScriptEventNorscaChallengersSpawned");
			
			if NorscaChallengersSpawned.is_started == false then
				NorscaChallengersSpawned:start();
			end
			
			NorscaChallengersSpawned.faction_key = faction_key;
			NorscaChallengersSpawned.god_key = god_key;
			NorscaChallengersSpawned.challengers_spawned = challengers_spawned;
			NorscaChallengersSpawned.missions_to_spawn = missions_to_spawn;
			core:trigger_event("ScriptEventNorscaChallengersSpawned");
		else
			cm:callback(function()
				for i = 1, #missions_to_spawn do
					out("Triggering MP Challenger mission: "..missions_to_spawn[i]);
					cm:trigger_mission(faction_key, missions_to_spawn[i], true, false, true);
				end
			end, 1);
		end
	end
end

NorscaChallengersSpawned = intervention:new("NorscaChallengersSpawned", 0, function() ChallengerCutscenePlay() end, BOOL_INTERVENTIONS_DEBUG);
NorscaChallengersSpawned:add_trigger_condition("ScriptEventNorscaChallengersSpawned", true);

function ChallengerCutscenePlay()
	local god_key = NorscaChallengersSpawned.god_key;
	local challengers_spawned = NorscaChallengersSpawned.challengers_spawned;
	
	local advice_to_play = {};
	advice_to_play[1] = "dlc08.camp.advice.nor.champions.001";
	advice_to_play[2] = "dlc08.camp.advice.nor.gods_"..god_key..".003";
	
	local cam_skip_x, cam_skip_y, cam_skip_d, cam_skip_b, cam_skip_h = cm:get_camera_position();
	NorscaChallengersSpawned.cam_skip_x = cam_skip_x;
	NorscaChallengersSpawned.cam_skip_y = cam_skip_y;
	NorscaChallengersSpawned.cam_skip_d = cam_skip_d;
	NorscaChallengersSpawned.cam_skip_b = cam_skip_b;
	NorscaChallengersSpawned.cam_skip_h = cam_skip_h;
	cm:take_shroud_snapshot();
	
	local challenger_cutscene = campaign_cutscene:new(
		"challenger_cutscene",
		23,
		function()
			cm:modify_advice(true);
			ChallengerCutsceneEnd();
		end
	);

	challenger_cutscene:set_skippable(true, function() ChallengerCutsceneSkipped(advice_to_play) end);
	challenger_cutscene:set_skip_camera(cam_skip_x, cam_skip_y, cam_skip_d, cam_skip_b, cam_skip_h);
	challenger_cutscene:set_disable_settlement_labels(false);
	challenger_cutscene:set_dismiss_advice_on_end(true);
	
	challenger_cutscene:action(
		function()
			cm:fade_scene(0, 3);
			cm:clear_infotext();
		end,
		0
	);
	
	challenger_cutscene:action(
		function()
			cm:show_shroud(false);
			cm:show_advice(advice_to_play[1]);
			
			local x_pos, y_pos = cm:log_to_dis(challengers_spawned[1][1], challengers_spawned[1][2]);
			cm:set_camera_position(x_pos, y_pos, cam_skip_d, cam_skip_b, cam_skip_h);
			cm:fade_scene(1, 2);
		end,
		3
	);
	
	challenger_cutscene:action(
		function()
			challenger_cutscene:wait_for_advisor();
		end,
		11
	);
	
	challenger_cutscene:action(
		function()
			cm:fade_scene(0, 1);
		end,
		12
	);
	
	challenger_cutscene:action(
		function()
			cm:show_advice(advice_to_play[2]);
			
			local x_pos, y_pos = cm:log_to_dis(challengers_spawned[2][1], challengers_spawned[2][2]);
			cm:set_camera_position(x_pos, y_pos, cam_skip_d, cam_skip_b, cam_skip_h);
			cm:fade_scene(1, 1);
		end,
		13
	);
		
	challenger_cutscene:action(
		function()
			challenger_cutscene:wait_for_advisor();
		end,
		21
	);
		
	challenger_cutscene:action(
		function()
			cm:fade_scene(0, 1);
		end,
		22
	);
		
	challenger_cutscene:action(
		function()
			cm:set_camera_position(cam_skip_x, cam_skip_y, cam_skip_d, cam_skip_b, cam_skip_h);
			cm:fade_scene(1, 1);
		end,
		23
	);
	
	challenger_cutscene:start();
end

function ChallengerCutsceneSkipped(advice_to_play)
	cm:override_ui("disable_advice_audio", true);
	
	effect.clear_advice_session_history();
	
	for i = 1, #advice_to_play do
		cm:show_advice(advice_to_play[i]);
	end;
	
	cm:callback(function() cm:override_ui("disable_advice_audio", false) end, 0.5);
	cm:restore_shroud_from_snapshot();
end;

function ChallengerCutsceneEnd()
	local faction_key = NorscaChallengersSpawned.faction_key;
	local missions_to_spawn = NorscaChallengersSpawned.missions_to_spawn;
	local cam_skip_x = NorscaChallengersSpawned.cam_skip_x;
	local cam_skip_y = NorscaChallengersSpawned.cam_skip_y;
	local cam_skip_d = NorscaChallengersSpawned.cam_skip_d;
	local cam_skip_b = NorscaChallengersSpawned.cam_skip_b;
	local cam_skip_h = NorscaChallengersSpawned.cam_skip_h;
	
	cm:set_camera_position(cam_skip_x, cam_skip_y, cam_skip_d, cam_skip_b, cam_skip_h);
	cm:restore_shroud_from_snapshot();
	cm:fade_scene(1, 1);
	
	for i = 1, #missions_to_spawn do
		cm:trigger_mission(faction_key, missions_to_spawn[i], true);
	end

	NorscaChallengersSpawned:complete();
end

function Spawn_Challenger(faction_key, god_key, is_mp)
	local invasion_key = "invasion_"..faction_key.."_"..god_key;
	local random_spawn_num = cm:random_number(#NORSCA_SPAWN_LOCATIONS);
	local random_spawn = NORSCA_SPAWN_LOCATIONS[random_spawn_num];
	local mission_spawn = nil;
	table.remove(NORSCA_SPAWN_LOCATIONS, random_spawn_num);
	
	local ram = random_army_manager;
	local unit_list = ram:generate_force("challenger_"..god_key, 19);
	
	local target_faction = cm:model():world():faction_by_key(faction_key);
	local challenger_invasion = invasion_manager:new_invasion(invasion_key, NORSCAN_CHALLENGER_FACTION_PREFIX..god_key, unit_list, random_spawn);
	
	if cm:is_multiplayer() == false then
		if target_faction:is_null_interface() == false and target_faction:has_faction_leader() == true then
			local faction_leader = target_faction:faction_leader();
			if faction_leader:is_null_interface() == false and faction_leader:has_military_force() == true then
				local faction_leader_cqi = faction_leader:command_queue_index();
				challenger_invasion:set_target("CHARACTER", faction_leader_cqi, faction_key);
			else
				challenger_invasion:set_target("NONE", nil, faction_key);
			end
		end
	end
	
	if cm:is_multiplayer() == false then
		-- Add army XP based on difficulty in SP
		local difficulty = cm:model():difficulty_level();
		
		if difficulty == -1 then
			-- Hard
			challenger_invasion:add_unit_experience(1);
		elseif difficulty == -2 then
			-- Very Hard
			challenger_invasion:add_unit_experience(2);
		elseif difficulty == -3 then
			-- Legendary
			challenger_invasion:add_unit_experience(3);
		end
	end
	
	-- Set up the General
	challenger_invasion:create_general(GOD_KEY_TO_CHALLENGER_DETAILS[god_key].make_faction_leader, GOD_KEY_TO_CHALLENGER_DETAILS[god_key].agent_subtype, GOD_KEY_TO_CHALLENGER_DETAILS[god_key].forename, GOD_KEY_TO_CHALLENGER_DETAILS[god_key].clan_name, GOD_KEY_TO_CHALLENGER_DETAILS[god_key].family_name, GOD_KEY_TO_CHALLENGER_DETAILS[god_key].other_name);
	
	challenger_invasion:add_character_experience(30, true); -- Level 30
	
	challenger_invasion:apply_effect(GOD_KEY_TO_CHALLENGER_DETAILS[god_key].effect_bundle, -1);
	
	challenger_invasion:start_invasion(
	function(self)
		local force = self:get_force();
		local force_cqi = force:command_queue_index();
		local force_leader_cqi = force:general_character():command_queue_index();
	
		NORSCAN_GODS[faction_key][god_key].challenger_cqi = force_cqi;
		NORSCAN_GODS[faction_key][god_key].challenger_force_cqi = force_leader_cqi;
		NORSCAN_GODS[faction_key][god_key].mission_record = "wh_dlc08_kill_challenger_"..god_key;
		
		if cm:is_multiplayer() == false then
			out("(SP) Preventing "..NORSCAN_CHALLENGER_FACTION_PREFIX..god_key.." diplomacy [all] with [all]");
			cm:force_diplomacy("faction:"..NORSCAN_CHALLENGER_FACTION_PREFIX..god_key, "all", "all", false, false, true);
		else
			out("(MP) Preventing "..NORSCAN_CHALLENGER_FACTION_PREFIX..god_key.." diplomacy [all] with [all]");
			cm:force_diplomacy("faction:"..NORSCAN_CHALLENGER_FACTION_PREFIX..god_key, "all", "all", false, false, true);
		end
	end,
	not is_mp
	);
	return random_spawn, "wh_dlc08_kill_challenger_"..god_key;
end

function Norsca_ChallengerTurnStart(context)
	local faction_name = context:faction():name();
	if CHAOS_CHALLENGER_FACTION_KEY_LOOKUP[faction_name] then
		cm:force_diplomacy("faction:"..faction_name, "all", "all", false, false, true);
	end
end

function Trigger_Final_Challenger(faction_key)
	if NORSCAN_GODS[faction_key] ~= nil then
		for key, data in pairs(NORSCAN_GODS[faction_key]) do
			if data.final == true then
				cm:trigger_mission(faction_key, "wh_dlc08_qb_chs_final_battle_"..key, true);
				Play_Norsca_Advice("dlc08.camp.advice.nor.champions.002");
				data.spawned = true;
				break;
			end
		end
	end
end


core:add_listener(
	"mission_succeeded_norsca_challenger_mission_check",
	"MissionSucceeded",
	true,
	function(context)
		ChallengerMissionCheck(context);
	end,
	true
);
	

core:add_listener(
	"mission_cancelled_norsca_challenger_mission_check",
	"MissionCancelled",
	true,
	function(context)
		-- Player can kill coop partners challengers, aborting the mission
		ChallengerMissionCheck(context);
	end,
	true
);


function ChallengerMissionCheck(context)
	local mission_key = context:mission():mission_record_key();
	local faction_key = context:faction():name();
	
	----------------------------------------------------
	---- ALLEGIANCE TO THE GODS - VICTORY CONDITION ----
	----------------------------------------------------
	if mission_key == "wh_dlc08_qb_chs_final_battle_khorne" or mission_key == "wh_dlc08_qb_chs_final_battle_nurgle" or mission_key == "wh_dlc08_qb_chs_final_battle_slaanesh" or mission_key == "wh_dlc08_qb_chs_final_battle_tzeentch" then
		if cm:is_multiplayer() == false then
			cm:complete_scripted_mission_objective("wh_main_short_victory", "defeat_chaos_gods_challengers", true);
			cm:complete_scripted_mission_objective("wh_main_long_victory", "defeat_chaos_gods_challengers", true);
			NORSCAN_CHAOS_INVASION_STATUS = "dilemma";
			cm:trigger_dilemma(faction_key, NORSCA_ARCHAON_DILEMMA);
		end
	--------------------------------------------
	---- ALLEGIANCE TO THE GODS - CHAPTER 1 ----
	--------------------------------------------
	elseif mission_key == "wh_dlc08_objective_01_"..faction_key then
		cm:trigger_mission(faction_key, "wh_dlc08_objective_02_"..faction_key, true);
	--------------------------------------------
	---- ALLEGIANCE TO THE GODS - CHAPTER 2 ----
	--------------------------------------------
	elseif mission_key == "wh_dlc08_objective_02_"..faction_key then
		cm:trigger_mission(faction_key, "wh_dlc08_objective_03_"..faction_key, true);
	--------------------------------------------
	---- ALLEGIANCE TO THE GODS - CHAPTER 3 ----
	--------------------------------------------
	elseif mission_key == "wh_dlc08_objective_03_"..faction_key then
		if cm:is_multiplayer() == false then
			cm:complete_scripted_mission_objective("wh_main_short_victory", "attain_chaos_god_favour", true);
			cm:complete_scripted_mission_objective("wh_main_long_victory", "attain_chaos_god_favour", true);
		end
	--------------------------------------------------------
	---- DEFEATED CHAOS CHALLENGERS - VICTORY CONDITION ----
	--------------------------------------------------------
	elseif NORSCAN_GODS[faction_key] ~= nil then
		for god_key, data in pairs(NORSCAN_GODS[faction_key]) do
			if data.mission_record == mission_key then
				data.defeated = true;
				local defeated_challengers = Has_Defeated_All_Challengers(faction_key);
				
				if defeated_challengers == true then
					Trigger_Final_Challenger(faction_key);
				end
				break;
			end
		end
	end
end

function Nosrca_DilemmaChoiceMadeEvent(context)
	local faction = context:faction();
	local dilemma = context:dilemma();
	local choice = context:choice();
	
	if DILEMMA_TO_GOD_EFFECTS[dilemma] ~= nil then
		if DILEMMA_TO_GOD_EFFECTS[dilemma][tostring(choice)] ~= nil then
			local god_key = DILEMMA_TO_GOD_EFFECTS[dilemma][tostring(choice)].god_key;
			local gain = DILEMMA_TO_GOD_EFFECTS[dilemma][tostring(choice)].gain;
			local loss = DILEMMA_TO_GOD_EFFECTS[dilemma][tostring(choice)].loss;
			
			Add_God_Favour(faction:name(), god_key, gain, loss);
		end
	end
end

function Give_Final_God_Reward(faction_key, god_key)
	if god_key == "tzeentch" then
		-- TZEENCH - Lord of Change
		local lord_ID = NORSCAN_REWARD_LORD_OF_CHANGE[faction_key];
		if lord_ID ~= nil then
			out("GOD REWARD: Unlocking Azrik the Mazekeeper!");
			cm:unlock_starting_general_recruitment(lord_ID, faction_key);
		end
	elseif god_key == "khorne" then
		-- KHORNE - Hellcannon
		local faction = cm:model():world():faction_by_key(faction_key);
		local faction_cqi = faction:command_queue_index();
		out("GOD REWARD: Unlocking Hellcannon Battery!");
		cm:remove_event_restricted_unit_record_for_faction(NORSCAN_REWARD_HELL_CANNON, faction:name());
	elseif god_key == "slaanesh" then
		-- SLAANESH - Super Agent
		local faction = cm:model():world():faction_by_key(faction_key);
		local faction_cqi = faction:command_queue_index();
		out("GOD REWARD: Spawning Kihar!");
		cm:disable_event_feed_events(true, "wh_event_category_traits_ancillaries", "", "");
		cm:disable_event_feed_events(true, "wh_event_category_character", "", "");
		cm:spawn_unique_agent(faction_cqi, NORSCAN_REWARD_SUPER_AGENT, false);
		cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_traits_ancillaries", "", "") end, 0.5);
		cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_character", "", "") end, 0.5);
	elseif god_key == "nurgle" then
		-- NURGLE - Plague
		local faction = cm:model():world():faction_by_key(faction_key);
		
		if faction:is_null_interface() == false and faction:has_faction_leader() == true then
			local faction_leader_X = faction:faction_leader():logical_position_x();
			local faction_leader_Y = faction:faction_leader():logical_position_y();
			

			StartPlagueNearPosition("wh2_main_plague_norsca", faction_key, "wh2_main_plague_norsca", faction_leader_X, faction_leader_Y);
			-- Old World
			GiveRegionPlague("wh2_main_plague_norsca", "wh_main_reikland_altdorf", true);
			GiveRegionPlague("wh2_main_plague_norsca", "wh_main_eastern_sylvania_castle_drakenhof", true);
			GiveRegionPlague("wh2_main_plague_norsca", "wh_main_death_pass_karak_drazh", true);
			GiveRegionPlague("wh2_main_plague_norsca", "wh_main_couronne_et_languille_couronne", true);
			GiveRegionPlague("wh2_main_plague_norsca", "wh_main_the_silver_road_karaz_a_karak", true);
			-- New World
			GiveRegionPlague("wh2_main_plague_norsca", "wh2_main_isthmus_of_lustria_hexoatl", true);
			GiveRegionPlague("wh2_main_plague_norsca", "wh2_main_eataine_lothern", true);
			GiveRegionPlague("wh2_main_plague_norsca", "wh2_main_iron_mountains_naggarond", true);
			GiveRegionPlague("wh2_main_plague_norsca", "wh2_main_headhunters_jungle_oyxl", true);
			GiveRegionPlague("wh2_main_plague_norsca", "wh2_main_land_of_the_dead_khemri", true);
		end
	end
end

function Norsca_UniqueAgentSpawned(context)
	local agent = context:unique_agent_details():character();
	
	if agent:is_null_interface() == false and agent:character_subtype("dlc08_nor_kihar") then
		if agent:rank() < 40 then
			local cqi = agent:cqi();
			cm:add_agent_experience("character_cqi:"..cqi, 40, true);
			cm:replenish_action_points("character_cqi:"..cqi);
			
			cm:callback(function()
				for i = 1, 40 do
					cm:force_add_skill("character_cqi:"..cqi, "wh_dlc08_skill_kihar_dummy");
				end
				cm:force_add_ancillary(agent, "wh_dlc08_anc_mount_nor_kihar_chaos_dragon", false, true);
			end, 0.5);
		end
	end
end

function Norsca_CharacterCreated(context)
	local agent = context:character();
	
	if agent:is_null_interface() == false and agent:character_subtype("wh_dlc08_nor_arzik") then
		out("AZRIK SPAWNED!");
		if agent:rank() < 30 then
			local cqi = agent:cqi();
			cm:add_agent_experience("character_cqi:"..cqi, 30, true);
			
			cm:callback(function()
				for i = 1, 30 do
					cm:force_add_skill("character_cqi:"..cqi, "wh_dlc08_skill_arzik_dummy");
				end
			end, 0.5);
		end
	end
end

function Has_Defeated_All_Challengers(faction_key)
	local at_least_one_spawned = false;
	if NORSCAN_GODS[faction_key] ~= nil then
		for god_key, data in pairs(NORSCAN_GODS[faction_key]) do
			if data.spawned == true then
				if data.defeated == false then
					return false;
				else
					at_least_one_spawned = true;
				end
			end
		end
	end
	return at_least_one_spawned;
end

function Has_Aligned_With_God(faction_key)
	if NORSCAN_GODS[faction_key] ~= nil then
		for god_key, data in pairs(NORSCAN_GODS[faction_key]) do
			if data.aligned == true then
				return true;
			end
		end
	end
	return false;
end

function Setup_Challenger_Armies()
	local ram = random_army_manager;
	
	for raze_id, god_key in pairs(RAZE_ID_TO_GOD_KEY) do
		ram:new_force("challenger_"..god_key);
		
		ram:add_unit("challenger_"..god_key, "wh_main_chs_inf_chaos_warriors_0", 1);
		ram:add_mandatory_unit("challenger_"..god_key, "wh_main_chs_inf_chaos_warriors_0", 4);
		ram:add_mandatory_unit("challenger_"..god_key, "wh_main_chs_inf_chaos_warriors_1", 2);
		
		ram:add_mandatory_unit("challenger_"..god_key, "wh_main_chs_inf_chosen_0", 2);
		ram:add_mandatory_unit("challenger_"..god_key, "wh_main_chs_inf_chosen_1", 2);
		
		ram:add_mandatory_unit("challenger_"..god_key, "wh_main_chs_cav_chaos_knights_0", 2);
		ram:add_mandatory_unit("challenger_"..god_key, "wh_main_chs_art_hellcannon", 2);
		
		ram:add_mandatory_unit("challenger_"..god_key, "wh_main_chs_mon_chaos_spawn", 2);
		ram:add_mandatory_unit("challenger_"..god_key, "wh_main_chs_mon_trolls", 2);
		ram:add_mandatory_unit("challenger_"..god_key, "wh_main_chs_mon_giant", 1);
	end
end

function Remove_Norscan_Challengers()
	cm:disable_event_feed_events(true, "wh_event_category_diplomacy", "", "");
	
	for raze_id, god_key in pairs(RAZE_ID_TO_GOD_KEY) do
		local target_faction = cm:model():world():faction_by_key(NORSCAN_CHALLENGER_FACTION_PREFIX..god_key);
		
		if target_faction:is_null_interface() == false and target_faction:has_faction_leader() == true then
			local faction_leader_cqi = target_faction:faction_leader():command_queue_index();
			cm:kill_character(faction_leader_cqi, true, true);
		end
	end
	
	cm:callback(function()
		cm:disable_event_feed_events(false, "wh_event_category_diplomacy", "", "");
	end, 1);
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("NORSCAN_GODS", NORSCAN_GODS, context);
		cm:save_named_value("NORSCA_SPAWN_LOCATIONS", NORSCA_SPAWN_LOCATIONS, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		NORSCAN_GODS = cm:load_named_value("NORSCAN_GODS", {}, context);
		NORSCA_SPAWN_LOCATIONS = cm:load_named_value("NORSCA_SPAWN_LOCATIONS", {}, context);
	end
);
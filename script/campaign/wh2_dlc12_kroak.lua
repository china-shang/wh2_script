local kroak_rank_unlock = 15;

local kroak_mission_started = false;
local kroak_spawned = false;
local kroak_reminder = 20;

local mazdamundi_faction = "wh2_main_lzd_hexoatl";
local kroq_gar_faction = "wh2_main_lzd_last_defenders";
local tehenhauin_faction = "wh2_dlc12_lzd_cult_of_sotek";
local tiktaqto_faction = "wh2_main_lzd_tlaqua";
local nakai_faction = "wh2_dlc13_lzd_spirits_of_the_jungle";
local gorrok_faction = "wh2_main_lzd_itza";
local oxyotl_faction = "wh2_dlc17_lzd_oxyotl";

ai_kroak_faction = {
	--Vortex Campaign
	--High Elves
	{campaign = "wh2_main_great_vortex", player = "wh2_main_hef_eataine", ai = tiktaqto_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_hef_order_of_loremasters", ai = gorrok_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_hef_avelorn", ai = oxyotl_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_hef_nagarythe", ai = mazdamundi_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc15_hef_imrik", ai = kroq_gar_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_hef_yvresse", ai = mazdamundi_faction},
	--Dark Elves
	{campaign = "wh2_main_great_vortex", player = "wh2_main_def_naggarond", ai = mazdamundi_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_def_cult_of_pleasure", ai = mazdamundi_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_def_har_ganeth", ai = mazdamundi_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc11_def_the_blessed_dread", ai = tehenhauin_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_def_hag_graef", ai = kroq_gar_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_twa03_def_rakarth", ai = oxyotl_faction},
	--Skaven
	{campaign = "wh2_main_great_vortex", player = "wh2_main_skv_clan_mors", ai = kroq_gar_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_skv_clan_pestilens", ai = tehenhauin_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc09_skv_clan_rictus", ai = mazdamundi_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_skv_clan_skyre", ai = tehenhauin_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_skv_clan_eshin", ai = tiktaqto_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_main_skv_clan_moulder", ai = oxyotl_faction},
	--Vampire Coast
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc11_cst_vampire_coast", ai = gorrok_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc11_cst_noctilus", ai = mazdamundi_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc11_cst_pirates_of_sartosa", ai = tiktaqto_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc11_cst_the_drowned", ai = mazdamundi_faction},
	--Tomb Kings
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc09_tmb_khemri", ai = tiktaqto_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc09_tmb_exiles_of_nehek", ai = mazdamundi_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc09_tmb_lybaras", ai = tehenhauin_faction},
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc09_tmb_followers_of_nagash", ai = tiktaqto_faction},
	--Empire
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc13_emp_the_huntmarshals_expedition", ai = mazdamundi_faction},
	--Dwarfs
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc17_dwf_thorek_ironbrow", ai = gorrok_faction},
	--Greenskins
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc15_grn_broken_axe", ai = tiktaqto_faction},
	--Bretonnia
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc14_brt_chevaliers_de_lyonesse", ai = tiktaqto_faction},
	--Beastmen
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc17_bst_taurox", ai = oxyotl_faction},
	--Wood Elves
	{campaign = "wh2_main_great_vortex", player = "wh2_dlc16_wef_sisters_of_twilight", ai = mazdamundi_faction},

	--Mortal Empires Campaign
	--High Elves
	{campaign = "main_warhammer", player = "wh2_main_hef_eataine", ai = mazdamundi_faction},
	{campaign = "main_warhammer", player = "wh2_main_hef_order_of_loremasters", ai = tehenhauin_faction},
	{campaign = "main_warhammer", player = "wh2_main_hef_avelorn", ai = mazdamundi_faction},
	{campaign = "main_warhammer", player = "wh2_main_hef_nagarythe", ai = mazdamundi_faction},
	{campaign = "main_warhammer", player = "wh2_dlc15_hef_imrik", ai = kroq_gar_faction},
	{campaign = "main_warhammer", player = "wh2_main_hef_yvresse", ai = tiktaqto_faction},
	--Dark Elves
	{campaign = "main_warhammer", player = "wh2_main_def_naggarond", ai = mazdamundi_faction},
	{campaign = "main_warhammer", player = "wh2_main_def_cult_of_pleasure", ai = mazdamundi_faction},
	{campaign = "main_warhammer", player = "wh2_main_def_har_ganeth", ai = mazdamundi_faction},
	{campaign = "main_warhammer", player = "wh2_dlc11_def_the_blessed_dread", ai = gorrok_faction},
	{campaign = "main_warhammer", player = "wh2_main_def_hag_graef", ai = kroq_gar_faction},
	{campaign = "main_warhammer", player = "wh2_twa03_def_rakarth", ai = oxyotl_faction},
	--Skaven
	{campaign = "main_warhammer", player = "wh2_main_skv_clan_mors", ai = kroq_gar_faction},
	{campaign = "main_warhammer", player = "wh2_main_skv_clan_pestilens", ai = gorrok_faction},
	{campaign = "main_warhammer", player = "wh2_dlc09_skv_clan_rictus", ai = mazdamundi_faction},
	{campaign = "main_warhammer", player = "wh2_main_skv_clan_skyre", ai = nakai_faction},
	{campaign = "main_warhammer", player = "wh2_main_skv_clan_eshin", ai = kroq_gar_faction},
	{campaign = "main_warhammer", player = "wh2_main_skv_clan_moulder", ai = oxyotl_faction},
	--Vampire Coast
	{campaign = "main_warhammer", player = "wh2_dlc11_cst_vampire_coast", ai = tehenhauin_faction},
	{campaign = "main_warhammer", player = "wh2_dlc11_cst_noctilus", ai = tehenhauin_faction},
	{campaign = "main_warhammer", player = "wh2_dlc11_cst_pirates_of_sartosa", ai = tiktaqto_faction},
	{campaign = "main_warhammer", player = "wh2_dlc11_cst_the_drowned", ai = mazdamundi_faction},
	--Tomb Kings
	{campaign = "main_warhammer", player = "wh2_dlc09_tmb_khemri", ai = tiktaqto_faction},
	{campaign = "main_warhammer", player = "wh2_dlc09_tmb_exiles_of_nehek", ai = mazdamundi_faction},
	{campaign = "main_warhammer", player = "wh2_dlc09_tmb_lybaras", ai = kroq_gar_faction},
	{campaign = "main_warhammer", player = "wh2_dlc09_tmb_followers_of_nagash", ai = tiktaqto_faction},
	--Empire
	{campaign = "main_warhammer", player = "wh_main_emp_empire", ai = nakai_faction},
	{campaign = "main_warhammer", player = "wh2_dlc13_emp_golden_order", ai = tiktaqto_faction},
	{campaign = "main_warhammer", player = "wh2_dlc13_emp_the_huntmarshals_expedition", ai = mazdamundi_faction},
	--Dwarfs
	{campaign = "main_warhammer", player = "wh_main_dwf_dwarfs", ai = kroq_gar_faction},
	{campaign = "main_warhammer", player = "wh_main_dwf_karak_izor", ai = tiktaqto_faction},
	{campaign = "main_warhammer", player = "wh_main_dwf_karak_kadrin", ai = kroq_gar_faction},
	{campaign = "main_warhammer", player = "wh2_dlc17_dwf_thorek_ironbrow", ai = kroq_gar_faction},
	--Greenskins
	{campaign = "main_warhammer", player = "wh_main_grn_greenskins", ai = kroq_gar_faction},
	{campaign = "main_warhammer", player = "wh_main_grn_crooked_moon", ai = tiktaqto_faction},
	{campaign = "main_warhammer", player = "wh_main_grn_orcs_of_the_bloody_hand", ai = kroq_gar_faction},
	{campaign = "main_warhammer", player = "wh2_dlc15_grn_broken_axe", ai = mazdamundi_faction},
	--Vampire Counts
	{campaign = "main_warhammer", player = "wh_main_vmp_vampire_counts", ai = tiktaqto_faction},
	{campaign = "main_warhammer", player = "wh2_dlc11_vmp_the_barrow_legion", ai = tiktaqto_faction},
	--Von Carsteins
	{campaign = "main_warhammer", player = "wh_main_vmp_schwartzhafen", ai = tiktaqto_faction},
	--Norsca
	{campaign = "main_warhammer", player = "wh_dlc08_nor_norsca", ai = nakai_faction},
	{campaign = "main_warhammer", player = "wh_dlc08_nor_wintertooth", ai = nakai_faction},
	--Bretonnia
	{campaign = "main_warhammer", player = "wh_main_brt_bretonnia", ai = nakai_faction},
	{campaign = "main_warhammer", player = "wh_main_brt_bordeleaux", ai = nakai_faction},
	{campaign = "main_warhammer", player = "wh_main_brt_carcassonne", ai = nakai_faction},
	{campaign = "main_warhammer", player = "wh2_dlc14_brt_chevaliers_de_lyonesse", ai = tiktaqto_faction},
	--Wood Elves
	{campaign = "main_warhammer", player = "wh_dlc05_wef_wood_elves", ai = tiktaqto_faction},
	{campaign = "main_warhammer", player = "wh_dlc05_wef_argwylon", ai = tiktaqto_faction},
	{campaign = "main_warhammer", player = "wh2_dlc16_wef_sisters_of_twilight", ai = mazdamundi_faction},
	{campaign = "main_warhammer", player = "wh2_dlc16_wef_drycha", ai = tiktaqto_faction},
	--Beastmen
	{campaign = "main_warhammer", player = "wh_dlc03_bst_beastmen", ai = tiktaqto_faction},
	{campaign = "main_warhammer", player = "wh2_dlc17_bst_malagor", ai = kroq_gar_faction},
	{campaign = "main_warhammer", player = "wh_dlc05_bst_morghur_herd", ai = tiktaqto_faction},
	{campaign = "main_warhammer", player = "wh2_dlc17_bst_taurox", ai = mazdamundi_faction},
	--Warriors of Chaos
	{campaign = "main_warhammer", player = "wh_main_chs_chaos", ai = mazdamundi_faction}
};


function add_kroak_listeners()
	
	out("#### Add Kroak Listeners ####");

	core:add_listener(
		"GiveKroakAncillaries",
		"UniqueAgentSpawned",
		function(context)
			return context:unique_agent_details():character():get_surname() == "names_name_894850662";
		end,
		function(context)
			
			local agent = context:unique_agent_details():character();

			if agent:is_null_interface() == false and agent:character_subtype("wh2_dlc12_lzd_lord_kroak") then
				out("KROAK SPAWNED!");
				if agent:rank() < 30 then
					local cqi = agent:cqi();
					
					cm:replenish_action_points(cm:char_lookup_str(cqi));
					
					

					cm:callback(function()
						cm:force_add_ancillary(agent, "wh2_dlc12_anc_arcane_item_standard_of_the_sacred_serpent", false, true);
						cm:force_add_ancillary(agent, "wh2_dlc12_anc_armour_glyph_of_potec", false, true);
						cm:force_add_ancillary(agent, "wh2_dlc12_anc_enchanted_item_golden_death_mask", false, true);
						cm:force_add_ancillary(agent, "wh2_dlc12_anc_talisman_amulet_of_itza", false, true);
						cm:force_add_ancillary(agent, "wh2_dlc12_anc_weapon_ceremonial_mace_of_malachite", false, true);
						
						cm:callback(function()
							CampaignUI.ClearSelection();
						end, 0.5);
					end, 0.5);
				end
			end
			
		end,
		false
	);

	local mazdamundi = cm:model():world():faction_by_key(mazdamundi_faction);
	local kroq_gar = cm:model():world():faction_by_key(kroq_gar_faction);
	local tehenhauin = cm:model():world():faction_by_key(tehenhauin_faction);
	local tiktaqto = cm:model():world():faction_by_key(tiktaqto_faction);
	local nakai = cm:model():world():faction_by_key(nakai_faction);
	local gorrok = cm:model():world():faction_by_key(gorrok_faction);
	local oxyotl = cm:model():world():faction_by_key(oxyotl_faction);
	
	local num_lizardmen_players = 0;
	local lzd_faction_key_1 = "";
	local lzd_faction_key_2 = "";
	
	local lzd_mission_key_1 = "";
	local lzd_mission_key_2 = "";
	
	if cm:get_faction(gorrok_faction):is_human() == true then
		
		spawn_kroak(gorrok_faction);		
		kroak_mission_started = true;

	elseif cm:is_multiplayer() then
		--Multiplayer
		local human_factions = cm:get_human_factions();
	
		for i = 1, #human_factions do
			if cm:get_faction(human_factions[i]):subculture() == "wh2_main_sc_lzd_lizardmen" then
				num_lizardmen_players = num_lizardmen_players+1;
				
				if num_lizardmen_players == 1 then
					lzd_faction_key_1 = cm:get_faction(human_factions[i]):name();
					
					if lzd_faction_key_1 == mazdamundi_faction then
						lzd_mission_key_1 = "mazdamundi_lord_kroak_stage_1";
					elseif lzd_faction_key_1 == kroq_gar_faction then
						lzd_mission_key_1 = "kroqgar_lord_kroak_stage_1";
					elseif lzd_faction_key_1 == tehenhauin_faction then
						lzd_mission_key_1 = "tehenhauin_lord_kroak_stage_1";
					elseif lzd_faction_key_1 == tiktaqto_faction then
						lzd_mission_key_1 = "tiktaqto_lord_kroak_stage_1";
					elseif lzd_faction_key_1 == nakai_faction then
						lzd_mission_key_1 = "nakai_lord_kroak_stage_1";
					elseif lzd_faction_key_1 == oxyotl_faction then
						lzd_mission_key_1 = "oxyotl_lord_kroak_stage_1";
					end;
				else
					lzd_faction_key_2 = cm:get_faction(human_factions[i]):name();
					
					if lzd_faction_key_2 == mazdamundi_faction then
						lzd_mission_key_2 = "mazdamundi_lord_kroak_stage_1";
					elseif lzd_faction_key_2 == kroq_gar_faction then
						lzd_mission_key_2 = "kroqgar_lord_kroak_stage_1";
					elseif lzd_faction_key_2 == tehenhauin_faction then
						lzd_mission_key_2 = "tehenhauin_lord_kroak_stage_1";
					elseif lzd_faction_key_2 == tiktaqto_faction then
						lzd_mission_key_2 = "tiktaqto_lord_kroak_stage_1";
					elseif lzd_faction_key_2 == nakai_faction then
						lzd_mission_key_2 = "nakai_lord_kroak_stage_1";
					elseif lzd_faction_key_2 == oxyotl_faction then
						lzd_mission_key_2 = "oxyotl_lord_kroak_stage_1";
					end;
				end
				
			end
		end
			
		if num_lizardmen_players == 2 then
			
			player_1_mission_key = "";
			player_2_mission_key = "";
					
			if cm:model():campaign_name("wh2_main_great_vortex") then
				player_1_mission_key = "wh2_dlc12_great_vortex_" .. lzd_mission_key_1;
				player_2_mission_key = "wh2_dlc12_great_vortex_" .. lzd_mission_key_2;
			else
				player_1_mission_key = "wh2_dlc12_" .. lzd_mission_key_1;
				player_2_mission_key = "wh2_dlc12_" .. lzd_mission_key_2;					
			end;
			
			core:add_listener(
				"mp_2_lzd_kroak_mission_generator",
				"CharacterTurnStart",
				function(context)
					local character = context:character();
					if character:is_faction_leader() and 
						character:faction():name() == lzd_faction_key_1 or character:faction():name() == lzd_faction_key_2 and
						character:rank() >= kroak_rank_unlock and 
						not kroak_mission_started then
						kroak_mission_started = true;
						return true;
					end;
					
					
					return false;
				end,
				function(context)
					cm:trigger_mission(lzd_faction_key_1, player_1_mission_key, true);
					cm:trigger_mission(lzd_faction_key_2, player_2_mission_key, true);
				end,
				false
			);
			
			core:add_listener(
				"mp_2_lzd_kroak_mission_succeeded",
				"MissionSucceeded",
				function(context)
					if context:faction():name() == lzd_faction_key_1 or context:faction():name() == lzd_faction_key_2  then
						return context:mission():mission_record_key():find("lord_kroak_stage_3");
					end;
					return false;
				end,
				function(context)
					if context:faction():name() == lzd_faction_key_1 then
						local length = string.len(player_2_mission_key);
						for i = 1, 3 do
							local mis_key = string.sub(player_2_mission_key,0,length-1);
							mis_key = mis_key .. tostring(i);
							cm:cancel_custom_mission(lzd_faction_key_2, mis_key);
						end
						spawn_kroak(lzd_faction_key_1);
					else
						local length = string.len(player_1_mission_key);
						for i = 1, 3 do
							local mis_key = string.sub(player_1_mission_key,0,length-1);
							mis_key = mis_key .. tostring(i);
							cm:cancel_custom_mission(lzd_faction_key_1, mis_key);
						end
						spawn_kroak(lzd_faction_key_2);
					end;
				end,
				false
			);
			
		elseif num_lizardmen_players == 1 then
			
			mission_key = "";
			
			if cm:model():campaign_name("wh2_main_great_vortex") then
				mission_key = "wh2_dlc12_great_vortex_" .. lzd_mission_key_1;
			else
				mission_key = "wh2_dlc12_" .. lzd_mission_key_1;					
			end;
			
			core:add_listener(
				"mp_1_lzd_kroak_mission_generator",
				"CharacterTurnStart",
				function(context)
					local character = context:character();
					if character:is_faction_leader() and 
						character:faction():name() == lzd_faction_key_1 and 
						not kroak_mission_started and 
						character:rank() >= kroak_rank_unlock then
						return true;
					end;
				end,
				function(context)
					kroak_mission_started = true;
					cm:trigger_mission(lzd_faction_key_1, mission_key, true);
				end,
				false
			);
			
			core:add_listener(
				"mp_1_lzd_kroak_mission_succeeded",
				"MissionSucceeded",
				function(context)
					if context:faction():name() == lzd_faction_key_1 then
						return context:mission():mission_record_key():find("lord_kroak_stage_3");
					end;
					return false;
				end,
				function(context)
					spawn_kroak(lzd_faction_key_1);
				end,
				false
			);
		else

			cm:add_faction_turn_start_listener_by_subculture(
				"mp_0_ai_lzd_kroak_reward",
				"wh2_main_sc_lzd_lizardmen",
				function(context)
					if context:faction():character_list():is_empty() == false then
						local character_list = context:faction():character_list();
						for i = 0, character_list:num_items() - 1 do
							local character = character_list:item_at(i);
							if character:rank() >= kroak_rank_unlock and character:is_faction_leader() and not kroak_mission_started then
								kroak_mission_started = true;
								assign_kroak_ai(context);
								cm:remove_faction_turn_start_listener_by_subculture("mp_0_ai_lzd_kroak_reward");
							end;
						end
					end
				end,
				true
			);

		end;
		
	else	
		--Single Player
		local faction_name = cm:get_local_faction_name();
		if faction_name then
			local faction = cm:get_faction(faction_name);
				--player LZD?
			if faction:subculture() == "wh2_main_sc_lzd_lizardmen" then	

				local mission_key = "";
				
				if faction_name == mazdamundi_faction then
					mission_key = "mazdamundi_lord_kroak_stage_1";
				elseif faction_name == kroq_gar_faction then
					mission_key = "kroqgar_lord_kroak_stage_1";
				elseif faction_name == tehenhauin_faction then
					mission_key = "tehenhauin_lord_kroak_stage_1";
				elseif faction_name == tiktaqto_faction then
					mission_key = "tiktaqto_lord_kroak_stage_1";
				elseif faction_name == nakai_faction then
					mission_key = "nakai_lord_kroak_stage_1";
				elseif faction_name == oxyotl_faction then
					mission_key = "oxyotl_lord_kroak_stage_1";
				end;
				
				if cm:model():campaign_name("wh2_main_great_vortex") then
					mission_key = "wh2_dlc12_great_vortex_" .. mission_key;
				else
					mission_key = "wh2_dlc12_" .. mission_key;				
				end;

				core:add_listener(
					"sp_kroak_mission_generator",
					"CharacterTurnStart",
					function(context)
						local character = context:character();
						if character:is_faction_leader() and 
							character:faction():name() == faction_name and 
							not kroak_mission_started and
							character:rank() >= kroak_rank_unlock then
							return true;
						end;
						return false;
					end,
					function(context)
						kroak_mission_started = true;
						cm:trigger_mission(faction_name, mission_key, true);
					end,
					false
				);
				
				core:add_listener(
					"sp_kroak_mission_succeeded",
					"MissionSucceeded",
					function(context)
						if context:faction():name() == faction_name then
							return context:mission():mission_record_key():find("lord_kroak_stage_3");
						end;
						return false;
					end,
					function(context)
						spawn_kroak(faction_name);
					end,
					false
				);
				
				cm:add_faction_turn_start_listener_by_name(
					"sp_kroak_mission_reminder",
					faction_name,
					function(context)	
						if kroak_mission_started then
							if kroak_spawned then
								return false;
							else
								if kroak_reminder <= 0 then
									kroak_reminder = 20;
									cm:trigger_incident(faction_name, "wh2_dlc12_incident_kroak_stirs", true);
									cm:remove_faction_turn_start_listener_by_name("sp_kroak_mission_reminder");
								else
									kroak_reminder = kroak_reminder - 1;
								end
							end
						end;
					end,
					true
				);

			else
				
				cm:add_faction_turn_start_listener_by_subculture(
					"sp_ai_lzd_kroak_reward",
					"wh2_main_sc_lzd_lizardmen",
					function(context)
						if context:faction():character_list():is_empty() == false then
							local character_list = context:faction():character_list();
							for i = 0, character_list:num_items() - 1 do
								local character = character_list:item_at(i);
								if character:rank() >= kroak_rank_unlock and character:is_faction_leader() and not kroak_mission_started then
									kroak_mission_started = true;
									assign_kroak_ai(context);
									cm:remove_faction_turn_start_listener_by_subculture("sp_ai_lzd_kroak_reward");
								end;
							end
						end
					end,
					true
				);
			end
		end
	end

end


function assign_kroak_ai(context)

	local human_factions = cm:get_human_factions();
	
	for i =1, #ai_kroak_faction do
		
		if ai_kroak_faction[i].campaign == cm:get_campaign_name() then
			local ai_faction = cm:get_faction(ai_kroak_faction[i].ai);
			local player_faction = cm:get_faction(ai_kroak_faction[i].player);
			if player_faction and ai_faction and player_faction:is_human() and not ai_faction:is_dead() and ai_faction:region_list():is_empty() == false then
				--assign kroak to this ai faction 
				spawn_kroak(ai_kroak_faction[i].ai);
				return;
			end;
		end;
	end;
	
	local faction_list = cm:model():world():faction_list();
	local num_factions = faction_list:num_items();
	
	for i = 0, num_factions - 1 do
		local fac = faction_list:item_at(i);
		if fac:subculture() == "wh2_main_sc_lzd_lizardmen" and fac:is_dead() == false and fac:region_list():is_empty() == false and fac:name() ~= "wh2_main_lzd_lizardmen_intervention" and fac:name():find("wh2_main_lzd_lizardmen_qb")	== false then
			--assign kroak to any living Lizardmen ai faction 
			spawn_kroak(faction_list:item_at(i):name());
		end;
	end;
	
end

function spawn_kroak(faction)

	cm:spawn_unique_agent(cm:get_faction(faction):command_queue_index(), "wh2_dlc12_lzd_lord_kroak", false);
	kroak_spawned = true;
end 


--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("kroak_mission_started", kroak_mission_started, context);
		cm:save_named_value("kroak_reminder", kroak_reminder, context);
		cm:save_named_value("kroak_spawned", kroak_spawned, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		kroak_mission_started = cm:load_named_value("kroak_mission_started", false, context);
		kroak_reminder = cm:load_named_value("kroak_reminder", 20, context);
		kroak_spawned = cm:load_named_value("kroak_spawned", false, context);
	end
);
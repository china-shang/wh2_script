local tehenhauin_faction = "wh2_dlc12_lzd_cult_of_sotek";

local  pos_1_1 = false;
local  pos_1_2 = false;

local  pos_2_1 = false;
local  pos_2_2 = false;
local  pos_2_3 = false;
local  pos_2_4 = false;

local  pos_3_1 = false;

-- {key = "ancillary key", anc = "type_tiernum"} e.g. ...}, {key = "wh2_main_anc_follower_lzd_architect",  anc = "follower_1"}, {...
local ancillary_list = {
	{key = "wh2_main_anc_follower_lzd_architect", anc = "follower"},
	{key = "wh2_main_anc_follower_lzd_astronomer", anc = "follower"},
	{key = "wh2_dlc12_lzd_anc_follower_piqipoqi_qupacoco", anc = "follower"},
	{key = "wh2_dlc12_lzd_anc_follower_chameleon_spotter", anc = "follower"},
	{key = "wh2_dlc12_lzd_anc_follower_swamp_trawler_skink", anc = "follower"},
	{key = "wh2_dlc12_lzd_anc_follower_prophets_spawn_brother", anc = "follower"},
	{key = "wh2_dlc12_lzd_anc_follower_consul_of_calith", anc = "follower"},
	{key = "wh2_dlc12_lzd_anc_follower_priest_of_the_star_chambers", anc = "follower"},
	{key = "wh2_dlc12_lzd_anc_follower_lotl_botls_spawn_brother", anc = "follower"},
	{key = "wh2_dlc12_lzd_anc_follower_obsinite_miner_skink", anc = "follower"},
	
	{key = "wh2_dlc12_lzd_anc_magic_standard_totem_of_the_spitting_viper", anc = "banner"},
	{key = "wh2_dlc12_lzd_anc_magic_standard_coatlpelt_flagstaff", anc = "banner"},
	{key = "wh2_dlc12_lzd_anc_magic_standard_exalted_banner_of_xapati", anc = "banner"},
	{key = "wh2_dlc12_lzd_anc_magic_standard_totem_pole_of_destiny", anc = "banner"},
	{key = "wh2_main_anc_magic_standard_sun_standard_of_chotec", anc = "banner"},
	{key = "wh2_main_anc_magic_standard_the_jaguar_standard", anc = "banner"},
	{key = "wh2_dlc12_lzd_anc_magic_standard_culchan_feathered_standard", anc = "banner"},
	{key = "wh2_dlc12_lzd_anc_magic_standard_flag_of_the_daystar", anc = "banner"},
	{key = "wh2_dlc12_lzd_anc_magic_standard_shroud_of_chaqua", anc = "banner"},
	{key = "wh2_dlc12_lzd_anc_magic_standard_sign_of_the_coiled_one", anc = "banner"}
};
restricted_buildings_list = {
	"wh2_main_lzd_saurus_1",
	"wh2_main_lzd_saurus_2",
	"wh2_main_lzd_saurus_3"
};

function add_tehenhauin_listeners()
	
	out("#### Adding Tehenhauin Listeners ####");
	local tehenhauin = cm:get_faction(tehenhauin_faction);
	
	if cm:is_new_game() == true then
		cm:faction_add_pooled_resource(tehenhauin_faction, "lzd_sacrificial_offerings", "wh2_dlc12_resource_factor_sacrifices_battle", 200);
		
		if tehenhauin and tehenhauin:is_human() then

			cm:trigger_mission(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_1_1", true);

			local pos_1_2_mm = mission_manager:new(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_1_2");
			pos_1_2_mm:set_mission_issuer("CLAN_ELDERS");
			pos_1_2_mm:add_new_objective("PERFORM_RITUAL");
			pos_1_2_mm:add_condition("ritual_category SACRIFICE_RITUAL");
			pos_1_2_mm:add_condition("total 5");
			pos_1_2_mm:add_payload("effect_bundle{bundle_key wh2_dlc12_prophecy_of_sotek_1_2;turns 0;}");
			pos_1_2_mm:add_payload("faction_pooled_resource_transaction{resource lzd_sacrificial_offerings;factor wh2_dlc12_resource_factor_sacrifices_missions;amount 200;}");
			
			pos_1_2_mm:trigger();
			
			cm:apply_effect_bundle("wh2_dlc12_prophecy_of_sotek_stage_1", tehenhauin_faction, -1);

		else
			
			local tehenhauin_char = cm:get_closest_general_to_position_from_faction(tehenhauin_faction, 190, 209, true);
			
			local units = {
			"wh2_dlc12_lzd_inf_skink_red_crested_0",
			"wh2_dlc12_lzd_inf_skink_red_crested_0",
			"wh2_dlc12_lzd_mon_salamander_pack_0",
			"wh2_dlc12_lzd_mon_ancient_salamander_0",
			"wh2_main_lzd_cav_horned_ones_0"
			};
			
			for i = 1, #units do
				cm:grant_unit_to_character(cm:char_lookup_str(tehenhauin_char), units[i]);
			end;
			
			if (cm:get_campaign_name() == "wh2_main_great_vortex") then
				
				--Forces Citadel of Dusk to declate war on Tehenauin
				cm:force_declare_war("wh2_main_hef_citadel_of_dusk", tehenhauin_faction, true, true);
				local culchain_plains_settlement = cm:get_region("wh2_main_vor_culchan_plains_kaiax"):settlement();

				--Upgrades Tehenhauins starting region
				cm:region_slot_instantly_upgrade_building(culchain_plains_settlement:primary_slot(), "wh2_main_lzd_settlement_major_3_coast");
				cm:region_slot_instantly_upgrade_building(culchain_plains_settlement:port_slot(), "wh2_main_lzd_port_2");

				local active_secondary_slots = culchain_plains_settlement:active_secondary_slots();
				cm:region_slot_instantly_upgrade_building(active_secondary_slots:item_at(0), "wh2_main_lzd_skinks_2");
				cm:region_slot_instantly_upgrade_building(active_secondary_slots:item_at(1), "wh2_main_lzd_saurus_2");
				
			else
				--Upgrades Tehenhauins starting region
				local xlanhuapec_settlement = cm:get_region("wh2_main_northern_great_jungle_xlanhuapec"):settlement();
				cm:region_slot_instantly_upgrade_building(xlanhuapec_settlement:primary_slot(), "wh2_main_lzd_settlement_major_3");
				
				local active_secondary_slots = xlanhuapec_settlement:active_secondary_slots();
				cm:region_slot_instantly_upgrade_building(active_secondary_slots:item_at(0), "wh2_main_lzd_skinks_2");
				cm:region_slot_instantly_upgrade_building(active_secondary_slots:item_at(1), "wh2_main_lzd_saurus_2");
				
			end
			
		end
		
	end
	
	core:add_listener(
		"pos_mission_success",
		"MissionSucceeded",
		true,
		function(context) 
			local mission_key = context:mission():mission_record_key();
			local faction = context:faction();
			
			if mission_key == "wh2_dlc12_prophecy_of_sotek_1_1" or mission_key == "wh2_dlc12_prophecy_of_sotek_1_1" then
			pos_1_1 = true;
				
				if pos_1_1 and pos_1_2 then
					core:trigger_event("ScriptEventPoSStage1Completed");
				end;
				
			elseif  mission_key == "wh2_dlc12_prophecy_of_sotek_1_2" then
				pos_1_2 = true;
				cm:callback(
					function()
						core:trigger_event("ScriptEventSacrificeTier2Unlocked", faction);
					end, 
					0.5
				);
					
				if pos_1_1 and pos_1_2 then
					core:trigger_event("ScriptEventPoSStage1Completed");
				end;
				
			elseif mission_key == "wh2_dlc12_prophecy_of_sotek_2_1" then
				pos_2_1 = true;
				
				if pos_2_1 and pos_2_2 and pos_2_3 and pos_2_4 then
					core:trigger_event("ScriptEventPoSStage2Completed");
				end;
				
			elseif  mission_key == "wh2_dlc12_prophecy_of_sotek_2_2" then
				pos_2_2 = true;
				
				if pos_2_1 and pos_2_2 and pos_2_3 and pos_2_4 then
					core:trigger_event("ScriptEventPoSStage2Completed");
				end;
				
			elseif  mission_key == "wh2_dlc12_prophecy_of_sotek_2_3" then
				pos_2_3 = true;
				
				core:trigger_event("ScriptEventSacrificeTier3Unlocked", faction);
				
				if pos_2_1 and pos_2_2 and pos_2_3 and pos_2_4 then
					core:trigger_event("ScriptEventPoSStage2Completed");
				end;
				
			elseif  mission_key == "wh2_dlc12_prophecy_of_sotek_2_4" then
				pos_2_4 = true;
				
				core:trigger_event("ScriptEventSacrificeTier4Unlocked", faction);
					
				if pos_2_1 and pos_2_2 and pos_2_3 and pos_2_4 then
					core:trigger_event("ScriptEventPoSStage2Completed");
				end;
				
			elseif  mission_key == "wh2_dlc12_prophecy_of_sotek_3_1" then
				pos_3_1 = true;
				
				core:trigger_event("ScriptEventSacrificeTier5Unlocked", faction);
			end;			
		end,
		true	
	);
	
	core:add_listener(
		"pos_stage_1_completed",
		"ScriptEventPoSStage1Completed",
		true,
		function() 
			
			if cm:is_multiplayer() then
				cm:trigger_mission(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_2_1", false);
				cm:trigger_mission(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_2_2", false);
				cm:trigger_mission(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_2_3", false);
				
				
				local pos_2_4_mm = mission_manager:new(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_2_4");
				pos_2_4_mm:set_mission_issuer("CLAN_ELDERS");
				pos_2_4_mm:add_new_objective("PERFORM_RITUAL");
				pos_2_4_mm:add_condition("ritual_category SACRIFICE_RITUAL");
				pos_2_4_mm:add_condition("total 5");
				pos_2_4_mm:add_payload("effect_bundle{bundle_key wh2_dlc12_prophecy_of_sotek_2_4;turns 0;}");
				pos_2_4_mm:add_payload("faction_pooled_resource_transaction{resource lzd_sacrificial_offerings;factor wh2_dlc12_resource_factor_sacrifices_missions;amount 200;}");
				
				pos_2_4_mm:trigger();
				
				cm:remove_effect_bundle("wh2_dlc12_prophecy_of_sotek_stage_1", tehenhauin_faction);
				cm:apply_effect_bundle("wh2_dlc12_prophecy_of_sotek_stage_2", tehenhauin_faction, -1);
			
			else
			
				cm:trigger_mission(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_2_1", true);
				cm:trigger_mission(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_2_2", true);
				cm:trigger_mission(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_2_3", true);
				
				
				local pos_2_4_mm = mission_manager:new(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_2_4");
				pos_2_4_mm:set_mission_issuer("CLAN_ELDERS");
				pos_2_4_mm:add_new_objective("PERFORM_RITUAL");
				pos_2_4_mm:add_condition("ritual_category SACRIFICE_RITUAL");
				pos_2_4_mm:add_condition("total 5");
				pos_2_4_mm:add_payload("effect_bundle{bundle_key wh2_dlc12_prophecy_of_sotek_2_4;turns 0;}");
				pos_2_4_mm:add_payload("faction_pooled_resource_transaction{resource lzd_sacrificial_offerings;factor wh2_dlc12_resource_factor_sacrifices_missions;amount 200;}");
				
				pos_2_4_mm:trigger();
				
				cm:remove_effect_bundle("wh2_dlc12_prophecy_of_sotek_stage_1", tehenhauin_faction);
				cm:apply_effect_bundle("wh2_dlc12_prophecy_of_sotek_stage_2", tehenhauin_faction, -1);
			
			end
			--change skaven / lizardmen diplomacy
			
						
			local lizardmen_faction_list = {};
			local skaven_faction_list = {};
			
			local faction_list = cm:model():world():faction_list();
			
			for i = 0, faction_list:num_items() - 1 do
				if (faction_list:item_at(i):subculture() == "wh2_main_sc_lzd_lizardmen") and (faction_list:item_at(i):is_dead() == false) then
					table.insert(lizardmen_faction_list, faction_list:item_at(i):name());
				end;
			end;
			
			for j = 0, faction_list:num_items() - 1 do
				if (faction_list:item_at(j):subculture() == "wh2_main_sc_skv_skaven") and (faction_list:item_at(j):is_dead() == false) then
					table.insert(skaven_faction_list, faction_list:item_at(j):name());
				end;
			end;
			
			
			for k = 1, #lizardmen_faction_list do
				
				cm:apply_effect_bundle("wh2_dlc12_prophecy_of_sotek_stage_2", lizardmen_faction_list[k], -1);
				
						for l = 1, #skaven_faction_list do
							if not cm:get_faction(skaven_faction_list[l]):is_human() then
								cm:force_declare_war(lizardmen_faction_list[k], skaven_faction_list[l], false, false);
							end
						end;
			end;
			
			for m = 1, #skaven_faction_list do
							
				cm:apply_effect_bundle("wh2_dlc12_prophecy_of_sotek_stage_2_skaven", skaven_faction_list[m], -1);
				cm:force_diplomacy("faction:" .. tehenhauin_faction, "faction:" .. skaven_faction_list[m], "peace", false, false, true);
			end;
			
		end,
		false	
	);
	
	core:add_listener(
		"pos_stage_2_completed",
		"ScriptEventPoSStage2Completed",
		true,
		function() 
			
			local pos_3_1_mm = mission_manager:new(tehenhauin_faction, "wh2_dlc12_prophecy_of_sotek_3_1");
			pos_3_1_mm:set_mission_issuer("CLAN_ELDERS");
			pos_3_1_mm:add_new_objective("PERFORM_RITUAL");
			pos_3_1_mm:add_condition("ritual_category SACRIFICE_RITUAL");
			pos_3_1_mm:add_condition("total 5");
			pos_3_1_mm:add_payload("effect_bundle{bundle_key wh2_dlc12_prophecy_of_sotek_3_1;turns 0;}");
			pos_3_1_mm:add_payload("faction_pooled_resource_transaction{resource lzd_sacrificial_offerings;factor wh2_dlc12_resource_factor_sacrifices_missions;amount 200;}");
			
			pos_3_1_mm:trigger();
			
			cm:remove_effect_bundle("wh2_dlc12_prophecy_of_sotek_stage_2", tehenhauin_faction);
			cm:apply_effect_bundle("wh2_dlc12_prophecy_of_sotek_stage_3", tehenhauin_faction, -1);
			
		end,
		false	
	);
	
	core:add_listener(
		"sacrifice_ancillary_listener",
		"RitualCompletedEvent",
		function(context) 
			if context:performing_faction():name() == tehenhauin_faction and tehenhauin:is_human() then
				return true;
			else
				return false;
			end
		end,
		function(context) 
			
			local ritual_key = context:ritual():ritual_key();
			local sublist_sort_key = "";
			
			if ritual_key == "wh2_dlc12_tehenhauin_sacrifice_tier2_banner" then
				sublist_sort_key = "banner";
			elseif ritual_key == "wh2_dlc12_tehenhauin_sacrifice_tier2_follower" then
				sublist_sort_key = "follower";
			end;
			
			--if we have a sublist sort key then we know we did a ritual that requires an ancillary to be rewarded
			if sublist_sort_key ~= "" then
				local ancillary_sublist = {};
				
				for i = 1, #ancillary_list do

					if ancillary_list[i].anc == sublist_sort_key then
						--add ancillary key to sublist if it keey the tier and type criteria
						table.insert(ancillary_sublist, ancillary_list[i].key);
					end
					
				end
				
				local rand_anc = ancillary_sublist[cm:random_number(#ancillary_sublist)];
				
				cm:add_ancillary_to_faction(context:performing_faction(), rand_anc, false); 
				
				
			end
			
		end,
		true	
	);
	core:add_listener(
		"sacrifice_effectbundlelistener",
		"MissionSucceeded",
		function(context) 
			local mission_key = context:mission():mission_record_key();
			if mission_key == "wh2_dlc12_prophecy_of_sotek_1_2" or mission_key == "wh2_dlc12_prophecy_of_sotek_2_3" or mission_key == "wh2_dlc12_prophecy_of_sotek_2_4" or mission_key == "wh2_dlc12_prophecy_of_sotek_3_1"then
				return true;
			end
			return false;
		end,
		function(context) 
			local mission_key = context:mission():mission_record_key();
			local effect_bundle = "";
			
			if mission_key == "wh2_dlc12_prophecy_of_sotek_1_2" then
				effect_bundle = "wh2_dlc12_prophecy_of_sotek_1_2";
			elseif mission_key == "wh2_dlc12_prophecy_of_sotek_2_3" then
				effect_bundle = "wh2_dlc12_prophecy_of_sotek_2_3";
			elseif mission_key == "wh2_dlc12_prophecy_of_sotek_2_4" then
				effect_bundle = "wh2_dlc12_prophecy_of_sotek_2_4";
			else
				effect_bundle = "wh2_dlc12_prophecy_of_sotek_3_1";
			end
			
			cm:callback(function() cm:remove_effect_bundle(effect_bundle, tehenhauin_faction) end, 0.5);

		end,
		true	
	);
	
	
end


--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("pos_1_1", pos_1_1, context);
		cm:save_named_value("pos_1_2", pos_1_2, context);
		
		cm:save_named_value("pos_2_1", pos_2_1, context);
		cm:save_named_value("pos_2_2", pos_2_2, context);
		cm:save_named_value("pos_2_3", pos_2_3, context);
		cm:save_named_value("pos_2_4", pos_2_4, context);
		
		cm:save_named_value("pos_3_1", pos_3_1, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		pos_1_1 = cm:load_named_value("pos_1_1", false, context);
		pos_1_2 = cm:load_named_value("pos_1_2", false, context);
		
		pos_2_1 = cm:load_named_value("pos_2_1", false, context);
		pos_2_2 = cm:load_named_value("pos_2_2", false, context);
		pos_2_3 = cm:load_named_value("pos_2_3", false, context);
		pos_2_4 = cm:load_named_value("pos_2_4", false, context);

		pos_3_1 = cm:load_named_value("pos_3_1", false, context);
	end
);
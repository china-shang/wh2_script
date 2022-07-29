
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	VORTEX RITUALS
--	This script manages vortex ritual events
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

require("wh2_vortex_ritual_settings");
require("wh2_vortex_ritual_interventions");

-- set this to false to disable ai handicap (gives free ritual currency if player is ahead)
local use_ai_handicap = true;

-- the area in which it is valid to spawn armies
-- min x, min y, max x, max y, region(s) to unshroud
local vortex_chaos_spawn_areas = {
	{175, 700, 202, 710,	{"wh2_main_vor_ironfrost_glacier_dagraks_end"}},
	{527, 691, 548, 715,	{"wh2_main_vor_aghol_wastelands_fortress_of_the_damned", "wh2_main_vor_aghol_wastelands_palace_of_princes"}},
	{518, 546, 550, 563,	{"wh2_main_vor_avelorn_evershale", "wh2_main_vor_avelorn_tor_saroir"}},
	{55, 574, 92, 590,		{"wh2_main_vor_plain_of_spiders_clarak_spire", "wh2_main_vor_plain_of_spiders_pits_of_zardok"}},
	{247, 90, 276, 124,		{"wh2_main_vor_the_lost_valleys_oyxl", "wh2_main_vor_culchan_plains_chupayotl", "wh2_main_vor_culchan_plains_the_southern_sentinels"}},
	{154, 258, 172, 274,	{"wh2_main_vor_the_creeping_jungle_tlaxtlan"}},
	{567, 214, 595, 229,	{"wh2_main_vor_shifting_sands_antoch", "wh2_main_vor_shifting_sands_plain_of_tuskers"}},
	{562, 137, 584, 152,	{"wh2_main_vor_the_red_rivers_cuexotl"}},
	{239, 543, 261, 566,	{"wh2_main_vor_shadow_wood_venom_glade", "wh2_main_vor_the_black_coast_vauls_anvil"}},
	{76, 701, 112, 715,		{"wh2_main_vor_ironfrost_glacier_ironfrost"}},
	{183, 623, 201, 636,	{"wh2_main_vor_naggarond_naggarond"}},
	{106, 368, 137, 384,	{"wh2_main_vor_isthmus_of_lustria_hexoatl", "wh2_main_vor_isthmus_of_lustria_monolith_of_fallen_gods"}},
	{174, 201, 202, 216,	{"wh2_main_vor_northern_great_jungle_chaqua", "wh2_main_vor_northern_great_jungle_itza", "wh2_main_vor_northern_great_jungle_quetza"}},
	{55, 212, 85, 237,		{"wh2_main_vor_jungles_of_green_mist_pillars_of_unseen_constellations", "wh2_main_vor_jungles_of_green_mist_wellsprings_of_eternity"}},
	{43, 497, 59, 520,		{"wh2_main_vor_ashen_coast_scarpels_lair"}},
	{623, 523, 638, 545,	{"wh2_main_vor_northern_yvresse_tor_yvresse"}},
	{412, 512, 424, 527,	{"wh2_main_vor_tiranoc_whitepeak"}},
	{406, 263, 443, 281,	{"wh2_main_vor_land_of_assassins_palace_of_the_wizard_caliph"}},
	{523, 271, 564, 288,	{"wh2_main_vor_land_of_the_dervishes_el-kalabad", "wh2_main_vor_land_of_the_dervishes_sudenburg", "wh2_main_vor_the_great_desert_bel_aliad", "wh2_main_vor_the_great_desert_pools_of_despair"}}
};

local vortex_norsca_spawn_areas = {
	{334, 298, 366, 319,	{"wh2_main_vor_sea_the_great_ocean"}},
	{409, 627, 452, 651,	{"wh2_main_vor_sea_northern_straits_of_the_great_ocean"}},
	{623, 375, 663, 397,	{"wh2_main_vor_sea_eastern_straits_of_the_great_ocean"}},
	{376, 43, 417, 68,		{"wh2_main_vor_sea_the_churning_gulf"}},
	{24, 20, 72, 35,		{"wh2_main_vor_sea_western_gulf_of_lustria"}},
	{19, 401, 50, 422,		{"wh2_main_vor_sea_far_sea"}},
	{13, 594, 24, 617,		{"wh2_main_vor_sea_boiling_sea"}},
	{349, 626, 369, 642,	{"wh2_main_vor_sea_sea_of_chill"}},
	{656, 47, 673, 70,		{"wh2_main_vor_sea_the_sea_of_dread"}}
};

-- display position of the vortex
vortex_cam_pos = {
	["x"] = 349.65,
	["y"] = 386.34,
	["d"] = 33,
	["b"] = 0,
	["h"] = 18
};

function vortex_setup()
	out.chaos("vortex_setup() called");
	
	cm:complete_scripted_mission_objective("wh2_main_vor_domination_victory", "domination", true);
	
	local local_faction = cm:get_local_faction_name(true);
	
	if local_faction then
		if cm:is_new_game() then
			vortex_start_interventions();
		end;
		
		-- disable vortex ritual event feed events if the player does not have ritual currency (e.g. nakai)
		if not cm:is_multiplayer() and not cm:get_faction(local_faction):has_pooled_resource("wh2_main_ritual_currency") and local_faction ~= "wh2_main_def_hag_graef" then
			cm:disable_event_feed_events(true, "", "wh_event_subcategory_faction_rituals", "");
		end;
	end;
	
	if cm:get_saved_value("player_lost_campaign") then
		vortex_complete_campaign(false);
	end;
	
	vortex_armies_setup();
	
	vortex_intervention_army_manager();
	
	vortex_setup_active_ritual_site_event_listeners();
	
	vortex_ai_confederation_listener();
	
	vortex_setup_active_incusion_death_monitors();
	
	-- listen for ritual start
	core:add_listener(
		"vortex_ritual_started",
		"RitualStartedEvent",
		function(context)
			local ritual_category = context:ritual():ritual_category();
			
			return ritual_category == "VORTEX_RITUAL" or ritual_category == "INTERVENTION_RITUAL";
		end,
		function(context)
			local ritual_category = context:ritual():ritual_category();
			local faction = context:performing_faction();
			
			if ritual_category == "VORTEX_RITUAL" then
				local ritual = context:ritual();
				local ritual_key = ritual:ritual_key();				
				local ritual_sites = ritual:ritual_sites();
				
				if ritual_sites:is_empty() then
					script_error("RitualStartedEvent triggered with VORTEX_RITUAL category, but no ritual sites - how can this happen?");
					return;
				end;
				
				local faction_name = faction:name();
				local turn_number = cm:model():turn_number();
				
				out.chaos("**********************************");
				out.chaos("* Vortex ritual started * [" .. faction_name .. "] has started [" .. ritual_key .. "] on round [" .. turn_number .. "] with a currency of [" .. faction:pooled_resource("wh2_main_ritual_currency"):value() .. "]");
				
				if faction:is_human() then
					out.chaos("* Faction is human");
					
					vortex_setup_ritual_site_event_listeners(faction, ritual_sites);
					
					-- check for ritual 5, need to play the horned rat movie on a delay
					if ritual_key:find("_5_") then
						cm:add_turn_countdown_event(faction_name, 10, "ScriptEventVortexRitual5Progress", faction_name);
					end;
				else
					out.chaos("* Faction is AI");
					
					if not cm:get_saved_value("ai_starts_first_ritual") then
						cm:set_saved_value("ai_starts_first_ritual", true);
					end;
				end;
				
				out.chaos("* The ritual sites are:");
				
				for i = 0, ritual_sites:num_items() - 1 do
					out.chaos("* " .. i + 1 .. " - [" .. ritual_sites:item_at(i):name() .. "]");
				end;
				
				out.chaos("**********************************");
				
				vortex_prepare_incursions(ritual, faction, true);
			else
				local target_faction_name = context:ritual_target_faction():name();
				local performing_faction_name = faction:name();
				local intervention_faction_name = faction:culture() .. "_intervention";
				
				out.chaos("Intervention performed by [" .. performing_faction_name .. "] against [" .. target_faction_name .. "], using intervention faction [" .. intervention_faction_name .. "]");
				
				cm:force_declare_war(intervention_faction_name, target_faction_name, false, false);
				cm:make_diplomacy_available(performing_faction_name, intervention_faction_name);
				cm:force_alliance(performing_faction_name, intervention_faction_name, true);
				cm:force_grant_military_access(performing_faction_name, intervention_faction_name, false);
				cm:force_diplomacy("faction:" .. intervention_faction_name, "all", "all", false, false, true);
			end;
		end,
		true
	);
	
	-- listen for ritual complete
	core:add_listener(
		"vortex_ritual_completed",
		"RitualCompletedEvent",
		function(context)
			return context:ritual():ritual_category() == "VORTEX_RITUAL";
		end,
		function(context)
			local ritual = context:ritual();
			local ritual_key = ritual:ritual_key();
			local faction = context:performing_faction();
			local faction_name = faction:name();
			local turn_number = cm:model():turn_number();
			local is_human = faction:is_human();
			
			out.chaos("**********************************");
			
			if context:succeeded() then
				remove_ritual_payload(ritual_key, faction_name);
				
				out.chaos("* Vortex ritual completed * [" .. faction_name .. "] has completed [" .. ritual_key .. "] on round [" .. turn_number .. "]");
				
				if is_human then
					out.chaos("* Faction is human");
					
					vortex_play_movie(faction, ritual_key);
				else
					out.chaos("* Faction is AI");
				end;
				
				if ritual_key:find("_1_") then
					-- start the chapter objectives
					if not cm:is_multiplayer() and is_human and chapter_one_mission then
						chapter_one_mission:manual_start();
					end;
				elseif ritual_key:find("_2_") then
					if not cm:get_saved_value("intercontinental_diplomacy_available") then
						make_intercontinental_diplomacy_available(true);
					end;
				elseif ritual_key:find("_4_") then
					if is_human then
						vortex_setup_comet_movie_listeners(faction_name);
					end;
					
					vortex_update_diplomatic_restrictions(faction_name, false);
				elseif ritual_key:find("_5_") then
					vortex_trigger_final_battle(faction);
				end;
			else
				out.chaos("* Vortex ritual failed * [" .. faction_name .. "] has failed [" .. ritual_key .. "] on round [" .. turn_number .. "]");
			end;
			
			if is_human then
				vortex_remove_ritual_site_event_listeners(ritual:ritual_sites());
			end;
			
			out.chaos("**********************************");
		end,
		true
	);
	
	-- play the horned rat movie
	core:add_listener(
		"ritual_5_progress",
		"ScriptEventVortexRitual5Progress",
		true,
		function(context)
			local faction_name = context.string;
			local faction = cm:get_faction(faction_name);
			
			cm:get_campaign_ui_manager():start_scripted_sequence();
			
			vortex_play_movie(faction, "horned_rat");
			
			-- spawn another wave of armies after the movie
			if faction:has_rituals() then
				local active_rituals = faction:rituals():active_rituals();
				
				if not active_rituals:is_empty() then
					vortex_prepare_incursions(active_rituals:item_at(0), faction, false);
					return;
				end;
			end;
			
			cm:get_campaign_ui_manager():stop_scripted_sequence();
		end,
		false
	);
	
	-- check if final battle missions fail
	core:add_listener(
		"final_battle_mission_expires",
		"MissionFailed",
		function(context)
			return context:mission():mission_record_key():find("wh2_main_qb_final_battle_");
		end,
		function(context)
			-- mission against the ai fails (player loses campaign)
			if context:mission():mission_record_key():find("_ai_") then
				vortex_complete_campaign(false);
			-- mission for the player fails (ritual progress is restarted)
			else
				local culture_prefix = vortex_get_culture_prefix(context:faction():culture());
				local ritual_chain = "wh2_main_ritual_" .. culture_prefix .. "_playablewh2_main_ritual_vortex_" .. culture_prefix;
				
				cm:rollback_linked_ritual_chain(ritual_chain, 4);
			end;
		end,
		true
	);
	
	-- not head to head
	if cm:model():campaign_type() ~= 2 then
		-- apply army abilities in the final battle
		core:add_listener(
			"final_battle_army_abilities",
			"PendingBattle",
			function()
				return vortex_pending_battle_is_final_battle(cm:model():pending_battle());
			end,
			function()
				local pb = cm:model():pending_battle();
				
				if not pb:set_piece_battle_key():find("_ai_") then
					local attacker = pb:attacker();
					local attacker_cqi = attacker:military_force():command_queue_index();
					
					out.chaos("Granting army abilities to attacker belonging to " .. attacker:faction():name());
					
					cm:apply_effect_bundle_to_force("wh2_main_bundle_final_battle_army_abilities", attacker_cqi, 0);
				end;
			end,
			true
		);
	end;
	
	-- player completes the final battle
	core:add_listener(
		"final_battle_clean_up",
		"BattleCompleted",
		function()
			return vortex_pending_battle_is_final_battle(cm:model():pending_battle());
		end,
		function()
			local pb = cm:model():pending_battle();
			
			local attacker = pb:attacker();
			local char_cqi = false;
			local mf_cqi = false;
			local faction_name = false;
			local has_been_fought = pb:has_been_fought();
			
			if has_been_fought then
				-- if the battle was fought, the attacker may have died, so get them from the pending battle cache
				char_cqi, mf_cqi, faction_name = cm:pending_battle_cache_get_attacker(1);
			else
				-- if the player retreated, the pending battle cache won't have stored the attacker, so get it from the attacker character (who should still be alive as they retreated!)
				faction_name = attacker:faction():name();
			end;
			
			local faction = cm:get_faction(faction_name);
			local culture = vortex_get_culture_prefix(faction:culture());
			
			local won = false;
			
			if has_been_fought and cm:pending_battle_cache_attacker_victory() then
				won = true;
			end;
			
			local set_piece_battle_key = pb:set_piece_battle_key();
			
			-- player has completed the ai final battle
			if set_piece_battle_key:find("_ai_") then
				if won then
					local primary_detail = "cultures_name_wh2_main_hef_high_elves";
					local secondary_detail = "event_feed_strings_text_wh2_event_feed_string_scripted_event_final_ritual_fails_secondary_detail_"
					local ai_culture = "hef";
					
					if set_piece_battle_key:find("_ai_hef") then
						secondary_detail = secondary_detail .. "hef";
					elseif set_piece_battle_key:find("_ai_def") then
						primary_detail = "cultures_name_wh2_main_def_dark_elves";
						secondary_detail = secondary_detail .. "def";
						ai_culture = "def";
					elseif set_piece_battle_key:find("_ai_lzd") then
						primary_detail = "cultures_name_wh2_main_lzd_lizardmen";
						secondary_detail = secondary_detail .. "lzd";
						ai_culture = "lzd";
					elseif set_piece_battle_key:find("_ai_skv") then
						primary_detail = "cultures_name_wh2_main_skv_skaven";
						secondary_detail = secondary_detail .. "skv";
						ai_culture = "skv";
					else
						return;
					end;
					
					cm:show_message_event(
						faction_name,
						"event_feed_strings_text_wh2_event_feed_string_scripted_event_final_ritual_fails_primary_detail",
						primary_detail,
						secondary_detail,
						true,
						vortex_get_event_pic_id(850, ai_culture)
					);
				elseif has_been_fought then
					cm:set_saved_value("player_lost_campaign", true);
					
					cm:disable_end_turn(true);
					cm:disable_shortcut("button_end_turn", "end_turn", true);
					cm:override_ui("disable_end_turn", true);
					cm:disable_shortcut("button_diplomacy", "show_diplomacy", true);
					cm:override_ui("disable_diplomacy", true);
					cm:disable_saving_game(true);
					
					local function show_event(faction_name, culture)
						cm:show_message_event(
							faction_name,
							"event_feed_strings_text_wh2_event_feed_string_scripted_event_player_loses_ai_final_battle_primary_detail",
							"",
							"event_feed_strings_text_wh2_event_feed_string_scripted_event_player_loses_ai_final_battle_secondary_detail_" .. culture,
							true,
							vortex_get_event_pic_id(860, culture)
						);
					end;
					
					if cm:is_multiplayer() then
						local human_factions = cm:get_human_factions();
						
						for i = 1, #human_factions do
							show_event(human_factions[i], vortex_get_culture_prefix(cm:get_faction(human_factions[i]):culture()));
						end;
					else
						show_event(faction_name, culture);
					end;
					
					core:add_listener(
						"player_game_over",
						"PanelClosedCampaign",
						function(context)
							return context.string == "events";
						end,
						function()
							vortex_complete_campaign(false);
						end,
						false
					);
				end;
			-- player has completed their final battle
			else
				if attacker then
					-- remove army ability effect bundle
					cm:remove_effect_bundle_from_force("wh2_main_bundle_final_battle_army_abilities", attacker:military_force():command_queue_index());
				end;
				
				if won then
					vortex_play_movie(faction, "win");
					
					-- lock all ritual chains so no more rituals can be started
					vortex_lock_ritual_chains();
					
					if attacker then
						-- all units that participated in the final battle become rank 9
						cm:add_experience_to_units_commanded_by_character(cm:char_lookup_str(attacker), 9);
					end;
					
					-- award xp to all player characters
					local character_list = faction:character_list();
					
					for i = 0, character_list:num_items() - 1 do
						cm:add_agent_experience(cm:char_lookup_str(character_list:item_at(i):cqi()), 8000);
					end;
					
					-- complete victory objective
					local dilemma = "wh2_main_dilemma_vortex_campaign_victory_hef_lzd";
					
					if culture == "def" or culture == "skv" then
						dilemma = "wh2_main_dilemma_vortex_campaign_victory_def_skv";
					end;
					
					if cm:is_multiplayer() then
						dilemma = dilemma .. "_mpc";
					end;
					
					cm:trigger_dilemma(faction_name, dilemma);
					
					core:add_listener(
						"continue_after_victory_dilemma",
						"DilemmaChoiceMadeEvent",
						function(context)
							return context:dilemma() == dilemma;
						end,
						function()
							vortex_complete_campaign(true);
							
							core:add_listener(
								"campaign_quit",
								"ComponentLClickUp",
								function(context)
									return context.string == "button_quit";
								end,
								function()
									core:svr_save_bool("sbool_frontend_play_credits_immediately", true);
								end,
								false
							);
						end,
						false
					);
					
					-- remove ritual diplomatic payload
					remove_ritual_payload(nil, faction_name, true);
					
					-- allow peace
					vortex_update_diplomatic_restrictions(faction_name, true);
					
					--[[cm:show_message_event(
						faction_name,
						"event_feed_strings_text_wh2_event_feed_string_scripted_event_campaign_won_primary_detail",
						"",
						"event_feed_strings_text_wh2_event_feed_string_scripted_event_campaign_won_secondary_detail",
						true,
						vortex_get_event_pic_id(870, culture)
					);]]
					
					cm:add_turn_countdown_event(faction_name, 2, "ScriptEventShowEpilogueEvent_" .. faction_name, faction_name);
				end;
			end;
		end,
		true
	);
	
	-- show the epilogue event
	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		if cm:get_faction(human_factions[i]):has_pooled_resource("wh2_main_ritual_currency") then
			core:add_listener(
				"epilogue",
				"ScriptEventShowEpilogueEvent_" .. human_factions[i],
				true,
				function(context)
					local faction_name = context.string;
					
					local culture = vortex_get_culture_prefix(cm:get_faction(faction_name):culture());
			
					cm:show_message_event(
						faction_name,
						"event_feed_strings_text_wh2_event_feed_string_scripted_event_epilogue_primary_detail",
						"",
						"event_feed_strings_text_wh2_event_feed_string_scripted_event_epilogue_secondary_detail_" .. culture,
						true,
						vortex_get_event_pic_id(880, culture)
					);
				end,
				false
			);
		end;
	end;
	
	-- cancel final battle missions if player wins via domination
	if not cm:is_multiplayer() and not cm:get_saved_value("domination_complete") then
		core:add_listener(
			"cancel_final_battles",
			"MissionSucceeded",
			function(context)
				return context:mission():mission_record_key() == "wh2_main_vor_domination_victory";
			end,
			function(context)				
				local faction = context:faction();
				local faction_name = faction:name();
				local player_culture_prefix = vortex_get_culture_prefix(faction:culture());
				
				-- cancel player final battle
				vortex_trigger_final_battle(faction, true);
				
				-- cancel ai final battles
				local ai_cultures = {
					"hef",
					"def",
					"lzd",
					"skv"
				};
				
				for i = 1, #ai_cultures do
					local current_ai_culture = ai_cultures[i];
					
					if player_culture_prefix ~= current_ai_culture and faction:culture():find("wh2_main_") then
						cm:cancel_custom_mission(faction_name, "wh2_main_qb_final_battle_" .. player_culture_prefix .. "_ai_" .. current_ai_culture);
					end;
				end;
				
				cm:set_saved_value("domination_complete", true);
			end,
			false
		);
	end;
	
	if use_ai_handicap then
		vortex_ai_handicap();
	end;
end;

-- remove the previous ritual's payload effect bundle as the diplomatic effects will stack otherwise
function remove_ritual_payload(ritual_key, faction_name, remove_all)
	local effect_bundle = "";
	
	if remove_all then
		effect_bundle = "wh2_main_ritual_vortex_5_" .. vortex_get_culture_prefix(cm:get_faction(faction_name):culture());
	else
		local stage = vortex_get_ritual_stage(ritual_key);
		
		if stage == 1 then
			return;
		elseif stage == 2 then
			effect_bundle = ritual_key:gsub("_2_", "_1_");
		elseif stage == 3 then
			effect_bundle = ritual_key:gsub("_3_", "_2_");
		elseif stage == 4 then
			effect_bundle = ritual_key:gsub("_4_", "_3_");
		elseif stage == 5 then
			effect_bundle = ritual_key:gsub("_5_", "_4_");
		end;
	end;
	
	cm:remove_effect_bundle(effect_bundle, faction_name);
end;

-- check if the pending battle is the final battle
function vortex_pending_battle_is_final_battle(pb)	
	return pb:set_piece_battle_key():find("wh2_main_qb_final_battle");
end;

function vortex_play_movie(faction, movie_type)
	-- the local faction is performing the ritual, or it's a co-op
	if cm:model():faction_is_local(faction:name()) or cm:model():campaign_type() == 4 then
		local culture = faction:culture();
		local movie_culture = vortex_get_culture_prefix(culture);
		local movie_str = "warhammer2/" .. movie_culture .. "/" .. movie_culture .. "_";
		local save_str = movie_culture .. "_";
		
		if movie_type == "win" or movie_type == "horned_rat" then
			movie_str = movie_str .. movie_type;
			save_str = save_str .. movie_type;
		elseif movie_type == "comet" then
			movie_str = "warhammer2/skv_comet";
			save_str = "skv_comet";
		else
			local stage = vortex_get_ritual_stage(movie_type);
			
			if not stage then
				script_error("ERROR: vortex_play_movie() called, but ritual key " .. movie_type .. " is not a known vortex ritual key!");
				return;
			end;
			
			stage = tostring(stage);
			
			movie_str = movie_str .. "ritual_" .. stage;
			save_str = save_str .. "ritual_"  .. stage;
		end;
		
		core:svr_save_registry_bool(save_str, true);
		cm:register_instant_movie(movie_str);
	end;
end;

function vortex_trigger_final_battle(faction, should_cancel)
	if cm:get_saved_value("domination_complete") then
		return;
	end;
	
	local mission = "wh2_main_qb_final_battle_";
	local culture_prefix = vortex_get_culture_prefix(faction:culture());
	local target_faction = faction:name();
	
	if faction:is_human() then
		-- the player has completed ritual 5
		mission = mission .. culture_prefix;
		
		local human_factions = cm:get_human_factions();
		
		if cm:model():campaign_type() == 2 then
			-- it's a head to head multiplayer game
			mission = mission .. "_head_to_head";
		elseif not cm:is_multiplayer() then
			-- it's single player (for co-op we always issue the main legendary lord version of the mission, as the victory conditions need to be synced)
			if target_faction == "wh2_main_hef_order_of_loremasters" then
				mission = mission .. "_teclis";
			elseif target_faction == "wh2_main_lzd_last_defenders" then
				mission = mission .. "_kroq_gar";
			elseif target_faction == "wh2_main_def_cult_of_pleasure" then
				mission = mission .. "_morathi";
			elseif target_faction == "wh2_main_skv_clan_pestilens" then
				mission = mission .. "_lord_skrolk";
			elseif target_faction == "wh2_dlc09_skv_clan_rictus" then
				mission = mission .. "_tretch";	
			elseif target_faction == "wh2_main_def_har_ganeth" then
				mission = mission .. "_hellebron";
			elseif target_faction == "wh2_main_hef_avelorn" then
				mission = mission .. "_alarielle";
			elseif target_faction == "wh2_main_hef_nagarythe" then
				mission = mission .. "_alith_anar";
			elseif target_faction == "wh2_dlc11_def_the_blessed_dread" then
				mission = mission .. "_lokhir";	
			elseif target_faction == "wh2_main_skv_clan_skyre" then
				mission = mission .. "_ikit_claw";	
			elseif target_faction == "wh2_dlc12_lzd_cult_of_sotek" then
				mission = mission .. "_tehenhauin";	
			elseif target_faction == "wh2_main_lzd_tlaqua" then
				mission = mission .. "_tiktaqto";	
			elseif target_faction == "wh2_main_lzd_itza" then
				mission = mission .. "_gor_rok";
			elseif target_faction == "wh2_dlc15_hef_imrik" then
				mission = mission .. "_imrik";
			end;
		end;
	else
		-- the AI has completed ritual 5
		local human_factions = cm:get_human_factions();
		local player_faction = human_factions[1];
		local player_culture_prefix = vortex_get_culture_prefix(cm:get_faction(player_faction):culture());
		
		mission = mission .. player_culture_prefix .. "_ai_" .. culture_prefix;
		target_faction = player_faction;
	end;
	
	if should_cancel then
		cm:cancel_custom_mission(target_faction, mission);
	else
		cm:trigger_mission(target_faction, mission, true);
	end;
end;

function vortex_prepare_incursions(ritual, faction, play_incursion_cutscene)
	local target_faction_name = faction:name();
	local ritual_key = ritual:ritual_key();
	local ritual_sites = ritual:ritual_sites();
	local num_ritual_sites = ritual_sites:num_items();
	local vortex_settings_difficulty = nil;
	local army_settings = nil;
	local camera_pos = {};
	local difficulty = vortex_get_difficulty();
	
	-- get the incursion settings based on difficulty
	for difficulty_level, settings in pairs(vortex_settings) do
		if difficulty == difficulty_level then
			vortex_settings_difficulty = settings;
		end;
	end;
	
	local stage = vortex_get_ritual_stage(ritual_key);
	
	if stage == 1 then
		army_settings = vortex_settings_difficulty.ritual_1;
	elseif stage == 2 then
		army_settings = vortex_settings_difficulty.ritual_2;
	elseif stage == 3 then
		army_settings = vortex_settings_difficulty.ritual_3;
	elseif stage == 4 then
		army_settings = vortex_settings_difficulty.ritual_4;
	elseif stage == 5 then
		army_settings = vortex_settings_difficulty.ritual_5;
	else
		script_error("ERROR: vortex_prepare_incursions() called, but ritual key " .. ritual_key .. " is not a known vortex ritual key!");
		return;
	end;
	
	-- get the average position of the ritual sites
	local x = 0;
	local y = 0;
	
	for i = 0, num_ritual_sites - 1 do
		local current_ritual_site = ritual_sites:item_at(i):settlement();
		
		x = x + current_ritual_site:logical_position_x();
		y = y + current_ritual_site:logical_position_y();
	end;
	
	x = x / num_ritual_sites;
	y = y / num_ritual_sites;
	
	-- get the closest set of spawn locations to the average ritual site position
	local coordinates = vortex_get_closest_positions(vortex_chaos_spawn_areas, x, y);
	
	if faction:is_human() then
		local camera_pos = {};
		local regions_to_unshroud = {};
		local army_positions = {};
		
		for i = 1, #army_settings.num_armies do
			if army_settings.num_armies[i] then
				local camera_pos_x, camera_pos_y, region_list, new_army_positions = vortex_spawn_incursions(i, coordinates, army_settings, target_faction_name, ritual_key, x, y, false, army_positions);
				
				army_positions = new_army_positions;
				
				-- if the above function returned a spawn location, then save it for the cutscene
				if camera_pos_x then
					table.insert(camera_pos, {["x"] = camera_pos_x, ["y"] = camera_pos_y});
					
					table.insert(regions_to_unshroud, region_list);
				end;
			end;
		end;
		
		-- play a cutscene if we have camera positions
		if play_incursion_cutscene then
			if camera_pos[2] then
				vortex_ritual_sites_cutscene(ritual_sites, target_faction_name, {camera_pos[1].x, camera_pos[1].y}, regions_to_unshroud[1], {camera_pos[2].x, camera_pos[2].y}, regions_to_unshroud[2]);
			elseif camera_pos[1] then
				vortex_ritual_sites_cutscene(ritual_sites, target_faction_name, {camera_pos[1].x, camera_pos[1].y}, regions_to_unshroud[1]);
			end;
		else
			vortex_horned_rat_cutscene(target_faction_name, {camera_pos[1].x, camera_pos[1].y}, regions_to_unshroud[1]);
		end;
	else
		for i = 1, #army_settings.num_armies_ai do
			if army_settings.num_armies_ai[i] then
				vortex_spawn_incursions(i, coordinates, army_settings, target_faction_name, ritual_key, x, y, true);
			end;
		end;
	end;
end;

function vortex_spawn_incursions(incursion_id, coordinates, army_settings, target_faction_name, ritual_key, x, y, ai, global_army_positions)	
	local culture = vortex_get_culture_prefix(cm:get_faction(target_faction_name):culture());
	
	local num_armies = 0;
	
	if ai then
		num_armies = cm:random_number(army_settings.num_armies_ai[incursion_id][2], army_settings.num_armies_ai[incursion_id][1]);
	else
		num_armies = cm:random_number(army_settings.num_armies[incursion_id][2], army_settings.num_armies[incursion_id][1]);
	end;
	
	local im = invasion_manager;
	
	local incursion_faction_name = "";
	
	global_army_positions = global_army_positions or {};
	
	local current_army_positions = {};
	
	local stage = vortex_get_ritual_stage(ritual_key);
	
	local effect_bundle = "wh_main_bundle_military_upkeep_free_force";
	
	for i = 1, num_armies do
		local is_valid = false;
		local chosen_position = nil;
		local units = nil;
		local ram = random_army_manager;
		
		if incursion_id == 1 then
			incursion_faction_name = "wh2_main_chs_chaos_incursion_" .. culture;
			
			effect_bundle = "wh2_main_bundle_military_upkeep_free_force_chaos_corruption";
			
			units = ram:generate_force("chaos_" .. stage, {army_settings.army_size[1], army_settings.army_size[2]});
		elseif incursion_id == 2 then
			incursion_faction_name = "wh2_main_nor_hung_incursion_" .. culture;
			
			coordinates = vortex_get_closest_positions(vortex_norsca_spawn_areas, x, y);
			
			units = ram:generate_force("norsca_" .. stage, {army_settings.army_size[1], army_settings.army_size[2]});
		else
			incursion_faction_name = "wh2_main_skv_unknown_clan_" .. culture;
			
			units = ram:generate_force("skaven_" .. stage, {army_settings.army_size[1], army_settings.army_size[2]});
		end;
		
		local count = 0;
		
		while not is_valid and count < 50 do
			chosen_position = {cm:random_number(coordinates[3], coordinates[1]), cm:random_number(coordinates[4], coordinates[2])};
			
			if is_valid_spawn_point(chosen_position[1], chosen_position[2]) then
				if #global_army_positions > 0 then
					for j = 1, #global_army_positions do
						-- check if the chosen position's distance to any of the previous positions
						if math.abs(chosen_position[1] - global_army_positions[j].x) > 3 or math.abs(chosen_position[2] - global_army_positions[j].y) > 3 then
							is_valid = true;
						else
							-- this position is too close to another, don't use it
							is_valid = false;
							break;
						end;
					end;
				else
					is_valid = true;
				end;
			end;
			
			count = count + 1;
		end;
		
		if is_valid then
			-- stash all army positions
			table.insert(global_army_positions, {["x"] = chosen_position[1], ["y"] = chosen_position[2]});
			table.insert(current_army_positions, {["x"] = chosen_position[1], ["y"] = chosen_position[2]});
			
			local invasion = im:new_invasion("turn_" .. tostring(cm:model():turn_number()) .. "_" .. ritual_key .. "_" .. incursion_faction_name .. "_" .. i, incursion_faction_name, units, chosen_position);
			invasion:set_target("NONE", nil, target_faction_name);
			invasion:apply_effect(effect_bundle, -1);
			
			local experience_amount = army_settings.character_experience[cm:random_number(3)];
			
			invasion:add_character_experience(experience_amount);
			invasion:add_unit_experience(army_settings.unit_rank);
			invasion:start_invasion(nil, false);
		else
			out.chaos("Warning! Could not spawn an army - make the spawn area that contains region [" .. coordinates[5][1] .. "] larger!");
		end;
	end;
	
	cm:disable_event_feed_events(true, "", "wh_event_subcategory_diplomacy_war_peace", "");
	
	cm:force_declare_war(incursion_faction_name, target_faction_name, false, false);
	cm:force_diplomacy("faction:" .. incursion_faction_name, "all", "all", false, false, true);
	
	cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_diplomacy_war_peace", "") end, 1);
	
	-- monitor for the target faction dying
	vortex_incursion_death_monitor(incursion_faction_name, target_faction_name);
	
	-- get the average position of the spawned armies
	local average_x = 0;
	local average_y = 0;
	
	for i = 1, #current_army_positions do
		local current_army_position = current_army_positions[i];
		
		average_x = average_x + current_army_position.x;
		average_y = average_y + current_army_position.y;
	end;
	
	average_x = average_x / #current_army_positions;
	average_y = average_y / #current_army_positions;
	
	return average_x, average_y, coordinates[5], global_army_positions;
end;

-- get all the spawn locations within a range and randomly return one
function vortex_get_closest_positions(coordinates, x, y)
	local closest_positions = {};
	local min_distance = 800;
	local max_distance = 30000;
	local found_position = false;
	
	while not found_position do
		for i = 1, #coordinates do
			-- get the centre point of the spawn area
			local centre_x = (coordinates[i][1] + coordinates[i][3]) / 2;
			local centre_y = (coordinates[i][2] + coordinates[i][4]) / 2;
			
			local current_distance = distance_squared(x, y, centre_x, centre_y);
			
			if current_distance < max_distance and current_distance > min_distance then
				table.insert(closest_positions, coordinates[i]);
			end;
		end;
		
		if #closest_positions < 1 then
			max_distance = max_distance + 5000;
		else
			found_position = true;
		end;
	end;
	
	local index = cm:random_number(#closest_positions);
	return closest_positions[index];
end;

function vortex_ritual_sites_cutscene(ritual_sites, faction_name, camera_pos, regions_to_unshroud, camera_pos_2, regions_to_unshroud_2)
	local coop = false;
	
	if cm:model():campaign_type() == 4 then
		coop = true;
	end;
	
	-- the local faction is performing the ritual, or it's a co-op
	if cm:model():faction_is_local(faction_name) or coop then
		local num_ritual_sites = ritual_sites:num_items();
		local ritual_sites_pos_x = {};
		local sorted_ritual_sites_pos = {};
		local cached_x, cached_y, cached_d, cached_b, cached_h = cm:get_camera_position();
		
		local settlement = cm:get_faction(faction_name):home_region():settlement();
		local capital_x = settlement:display_position_x();
		local capital_y = settlement:display_position_y();
		
		-- build a table of the ritual site display position x and the name
		for i = 0, num_ritual_sites - 1 do
			local current_site = ritual_sites:item_at(i):settlement();
			
			table.insert(ritual_sites_pos_x, {current_site:display_position_x(), current_site:region():name()});
		end;
		
		-- sort the table in ascending order
		table.sort(ritual_sites_pos_x, function(a, b) return a[1] < b[1] end);
		
		-- build a table of the ritual site display positions based on the sorted order
		for i = 1, #ritual_sites_pos_x do
			for j = 0, num_ritual_sites - 1 do
				local current_site = ritual_sites:item_at(j):settlement();
				
				if ritual_sites_pos_x[i][2] == current_site:region():name() then
					table.insert(sorted_ritual_sites_pos, {current_site:display_position_x(), current_site:display_position_y()});
				end;
			end;
		end;
		
		local chaos_armies_cutscene_length = 10;
		
		if camera_pos_2 then
			chaos_armies_cutscene_length = chaos_armies_cutscene_length + 2;
		end;
		
		local chaos_armies_cutscene = campaign_cutscene:new(
			"chaos_armies",
			chaos_armies_cutscene_length
		);
		
		local ritual_sites_cutscene = campaign_cutscene:new(
			"ritual_sites",
			(num_ritual_sites * 2) + 8.5,
			function()
				chaos_armies_cutscene:start();
			end
		);
		
		ritual_sites_cutscene:set_disable_settlement_labels(false);
		ritual_sites_cutscene:set_restore_shroud(false);
		
		ritual_sites_cutscene:action(
			function()
				cm:fade_scene(0, 0.5);
				cm:take_shroud_snapshot();
				
				if coop then
					local human_factions = cm:get_human_factions();
					
					for i = 1, #human_factions do
						cm:make_region_visible_in_shroud(human_factions[i], "wh2_main_vor_the_isle_of_the_dead");
					end;
				else
					cm:make_region_visible_in_shroud(faction_name, "wh2_main_vor_the_isle_of_the_dead");
				end;
			end,
			0
		);
		
		-- cut to first ritual site
		ritual_sites_cutscene:action(
			function()
				cm:show_advice("wh2.camp.advice.vortex_ritual.010", true);
				
				cm:set_camera_position(sorted_ritual_sites_pos[1][1], sorted_ritual_sites_pos[1][2], 16.7, 0, 14);
			end,
			0.5
		);
		
		ritual_sites_cutscene:action(
			function()
				cm:fade_scene(1, 0.5);
			end,
			0.7
		);
		
		local current_time = 1.5
		
		-- show each ritual site
		for i = 2, #sorted_ritual_sites_pos do
			local current_x = sorted_ritual_sites_pos[i][1];
			local current_y = sorted_ritual_sites_pos[i][2];
			
			-- if the ritual sites are close then pan
			if distance_squared(current_x, current_y, sorted_ritual_sites_pos[i - 1][1], sorted_ritual_sites_pos[i - 1][2]) < 11000 then
				ritual_sites_cutscene:action(
					function()
						cm:scroll_camera_from_current(false, 1, {current_x, current_y, 16.7, 0, 14});
					end,
					current_time
				);
			-- otherwise cut
			else
				ritual_sites_cutscene:action(
					function()
						cm:fade_scene(0, 0.5);
					end,
					current_time
				);
				
				ritual_sites_cutscene:action(
					function()
						cm:set_camera_position(current_x, current_y, 16.7, 0, 14);
						cm:fade_scene(1, 0.5);
					end,
					current_time + 0.5
				);
			end;
			
			current_time = current_time + 2;
		end;
		
		-- pan to vortex
		ritual_sites_cutscene:action(
			function()
				cm:scroll_camera_from_current(false, 5, {vortex_cam_pos.x, vortex_cam_pos.y, vortex_cam_pos.d, -0.12, 20});
			end,
			current_time + 2
		);
		
		ritual_sites_cutscene:action(
			function()
				cm:scroll_camera_from_current(false, 3, {vortex_cam_pos.x, vortex_cam_pos.y, vortex_cam_pos.d, -0.08, 18});
				
				ritual_sites_cutscene:wait_for_advisor()
			end,
			current_time + 7
		);
		
		ritual_sites_cutscene:action(
			function()
				cm:fade_scene(0, 0.5);
			end,
			current_time + 8
		);
		
		-- cut to capital
		ritual_sites_cutscene:action(
			function()
				cm:set_camera_position(capital_x, capital_y, 16.7, 0, 14);
				
				cm:fade_scene(1, 0.5);
			end,
			current_time + 8.5
		);
		
		ritual_sites_cutscene:set_skippable(
			true,
			function()
				cm:fade_scene(0, 0);
				
				cm:callback(function() cm:fade_scene(1, 0.5) end, 0.5);
			end
		);
		
		chaos_armies_cutscene:set_disable_settlement_labels(false);
		chaos_armies_cutscene:set_restore_shroud(false);
		
		local chaos_armies_cutscene_timer = 1;
		
		local pos_x, pos_y = cm:log_to_dis(camera_pos[1], camera_pos[2]);
		
		-- ensure the camera is set to the capital
		chaos_armies_cutscene:action(
			function()
				cm:set_camera_position(capital_x, capital_y, 16.7, 0, 14);
			end,
			0
		);
		
		-- pan to chaos armies
		chaos_armies_cutscene:action(
			function()
				cm:scroll_camera_from_current(false, 4, {pos_x, pos_y, 16.7, -0.12, 17});
				
				cm:show_advice("wh2.camp.advice.vortex_ritual.011", true);
				
				for i = 1, #regions_to_unshroud do
					if coop then
						local human_factions = cm:get_human_factions();
						
						for j = 1, #human_factions do
							cm:make_region_visible_in_shroud(human_factions[j], regions_to_unshroud[i]);
						end;
					else
						cm:make_region_visible_in_shroud(faction_name, regions_to_unshroud[i]);
					end;
				end;
			end,
			chaos_armies_cutscene_timer
		);
		
		chaos_armies_cutscene:action(
			function()
				cm:scroll_camera_from_current(false, 4, {pos_x, pos_y, 16.7, -0.08, 14});
			end,
			chaos_armies_cutscene_timer + 4.5
		);
		
		-- pan to norsca armies, if we have them
		if camera_pos_2 then
			local pos_2_x, pos_2_y = cm:log_to_dis(camera_pos_2[1], camera_pos_2[2]);
			
			chaos_armies_cutscene:action(
				function()
					cm:scroll_camera_from_current(false, 2, {pos_2_x, pos_2_y, 16.7, -0.12, 17});
					
					for i = 1, #regions_to_unshroud_2 do
						if coop then
							local human_factions = cm:get_human_factions();
							
							for j = 1, #human_factions do
								cm:make_region_visible_in_shroud(human_factions[j], regions_to_unshroud_2[i]);
							end;
						else
							cm:make_region_visible_in_shroud(faction_name, regions_to_unshroud_2[i]);
						end;
					end;
				end,
				chaos_armies_cutscene_timer + 7.5
			);
			
			chaos_armies_cutscene:action(
				function()
					cm:scroll_camera_from_current(false, 4, {pos_2_x, pos_2_y, 16.7, -0.08, 14});
				end,
				chaos_armies_cutscene_timer + 9.5
			);
			
			chaos_armies_cutscene_timer = chaos_armies_cutscene_timer + 2;
		end;
		
		chaos_armies_cutscene:action(
			function()
				cm:fade_scene(0, 0.5);
			end,
			chaos_armies_cutscene_timer + 8.5
		);
		
		local function end_cutscene()
			cm:set_camera_position(cached_x, cached_y, cached_d, cached_b, cached_h);
			cm:restore_shroud_from_snapshot();
			cm:fade_scene(1, 0.5);
		end;
		
		-- cut back to original position
		chaos_armies_cutscene:action(
			function()
				end_cutscene();
			end,
			chaos_armies_cutscene_timer + 9
		);
		
		chaos_armies_cutscene:set_skippable(
			true,
			function()
				cm:fade_scene(0, 0);
				
				cm:callback(
					function()
						end_cutscene();
					end,
					0.5
				);
			end
		);
		
		ritual_sites_cutscene:start();
	end;
end;

function vortex_horned_rat_cutscene(faction_name, camera_pos, regions_to_unshroud)
	local faction = cm:get_faction(faction_name);
	local coop = false;
	
	if cm:model():campaign_type() == 4 then
		coop = true;
	end;
	
	-- the local faction is performing the ritual, or it's a co-op
	if cm:model():faction_is_local(faction_name) or coop then
		local cached_x, cached_y, cached_d, cached_b, cached_h = cm:get_camera_position();
		
		local settlement = faction:home_region():settlement();
		local capital_x = settlement:display_position_x();
		local capital_y = settlement:display_position_y();
		
		local advice = "wh2.camp.advice.horned_rat.001";
		
		if faction:culture() == "wh2_main_skv_skaven" then
			advice = "wh2.camp.advice.horned_rat.002";
		end;
		
		local cutscene = campaign_cutscene:new(
			"horned_rat",
			17.5
		);
		
		cutscene:set_disable_settlement_labels(false);
		cutscene:set_restore_shroud(false);
		
		-- cut to player's capital
		cutscene:action(
			function()
				cm:fade_scene(0, 0);
				cm:take_shroud_snapshot();
				cm:set_camera_position(capital_x, capital_y, 16.7, 0, 10);
			end,
			0
		);
		
		cutscene:action(
			function()
				cm:fade_scene(1, 0.5);
				cm:show_advice(advice, true);
			end,
			1
		);
		
		local pos_x, pos_y = cm:log_to_dis(camera_pos[1], camera_pos[2]);
		
		-- pan to skaven armies
		cutscene:action(
			function()
				cm:scroll_camera_from_current(false, 10, {pos_x, pos_y, 16.7, -0.12, 14});
				
				for i = 1, #regions_to_unshroud do
					if coop then
						local human_factions = cm:get_human_factions();
						
						for j = 1, #human_factions do
							cm:make_region_visible_in_shroud(human_factions[j], regions_to_unshroud[i]);
						end;
					else
						cm:make_region_visible_in_shroud(faction_name, regions_to_unshroud[i]);
					end;
				end;
			end,
			2
		);
		
		-- pan to skaven armies
		cutscene:action(
			function()
				cm:scroll_camera_from_current(false, 3, {pos_x, pos_y, 16.7, -0.08, 13});
			end,
			12
		);
		
		cutscene:action(
			function()
				cm:fade_scene(0, 0.5);
			end,
			17
		);
		
		local function end_cutscene()
			cm:set_camera_position(cached_x, cached_y, cached_d, cached_b, cached_h);
			cm:restore_shroud_from_snapshot();
			cm:fade_scene(1, 0.5);
			cm:get_campaign_ui_manager():stop_scripted_sequence();
		end;
		
		-- cut back to original position
		cutscene:action(
			function()
				end_cutscene();
			end,
			17.5
		);
		
		cutscene:set_skippable(
			true,
			function()			
				cm:fade_scene(0, 0);
				
				cm:callback(
					function()
						end_cutscene();
					end,
					0.5
				);
			end
		);
		
		cutscene:start();
	end;
end;

function is_valid_spawn_point(x, y)
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local char_list = current_faction:character_list();
		
		for i = 0, char_list:num_items() - 1 do
			local current_char = char_list:item_at(i);
			if current_char:logical_position_x() == x and current_char:logical_position_y() == y then
				return false;
			end;
		end;
	end;
	
	return true;
end;

function vortex_get_culture_prefix(culture)
	if culture == "wh2_main_hef_high_elves" then
		return "hef";
	elseif culture == "wh2_main_def_dark_elves" then
		return "def";
	elseif culture == "wh2_main_lzd_lizardmen" then
		return "lzd";
	elseif culture == "wh2_main_skv_skaven" then
		return "skv";
	else
		return "";
	end;
end;

-- if the player is ahead of the ai, give the ai ritual currency
function vortex_ai_handicap()

	-- do nothing if we have no human faction (autorun) or the human faction does not support ritual currency (tomb kings)
	do 
		local human_faction_key = cm:get_human_factions()[1];

		if not is_string(human_faction_key) then
			return false;
		end;

		local human_faction = cm:get_faction(cm:get_human_factions()[1]);
		
		if not (human_faction and human_faction:has_pooled_resource("wh2_main_ritual_currency")) then
			return false;
		end;
	end;


	local difficulty_level_modifier = {
		["easy"]		= 9,
		["normal"]		= 8,
		["hard"]		= 7,
		["very_hard"]	= 6,
		["legendary"]	= 5
	};
	
	local difficulty = vortex_get_difficulty();
	local ai_handicap = 0;
	
	-- get the handicap modifier based on difficulty
	for difficulty_level, modifier in pairs(difficulty_level_modifier) do
		if difficulty == difficulty_level then
			ai_handicap = modifier;
		end;
	end;
	
	-- each ai turn, compare progress between player, if player is ahead, add currency to ai
	core:add_listener(
		"vortex_ai_handicap",
		"FactionTurnStart",
		function(context)
			local faction = context:faction();
			
			return not faction:is_human() and faction:has_rituals() and faction:has_access_to_ritual_category("VORTEX_RITUAL");
		end,
		function(context)
			local ai_faction = context:faction();
			local human_faction = cm:get_faction(cm:get_human_factions()[1]);
			
			local human_faction_ritual_currency = human_faction:pooled_resource("wh2_main_ritual_currency"):value();
			local ai_faction_ritual_currency = ai_faction:pooled_resource("wh2_main_ritual_currency"):value();
			
			if human_faction_ritual_currency > ai_faction_ritual_currency then
				local currency_mod = math.floor((human_faction_ritual_currency - ai_faction_ritual_currency) / ai_handicap);
				local cqi = ai_faction:command_queue_index();
				
				out.chaos("********");
				out.chaos("Player has [" .. human_faction_ritual_currency .. "] ritual currency and faction [" .. ai_faction:name() .. "] has [" .. ai_faction_ritual_currency .. "] ritual currency");
				out.chaos("Adding [" .. currency_mod .. "]");
				out.chaos("********");
				
				cm:pooled_resource_mod(cqi, "wh2_main_ritual_currency", "wh2_main_resource_factor_other", currency_mod);
			end;
		end,
		true
	);
end;

function vortex_get_difficulty()
	local difficulty = cm:model():combined_difficulty_level();
	
	local local_faction = cm:get_local_faction_name(true);
	
	if local_faction and cm:get_faction(local_faction) then
		if difficulty == 0 then
			difficulty = "normal";
		elseif difficulty == -1 then
			difficulty = "hard";
		elseif difficulty == -2 then
			difficulty = "very_hard";
		elseif difficulty == -3 then
			difficulty = "legendary";
		else
			difficulty = "easy";
		end;
	else
	-- autorun
		if difficulty == 0 then
			difficulty = "normal";
		elseif difficulty == 1 then
			difficulty = "hard";
		elseif difficulty == 2 then
			difficulty = "very_hard";
		elseif difficulty == 3 then
			difficulty = "legendary";
		else
			difficulty = "easy";
		end;
	end;
	
	return difficulty;
end;

-- give intervention armies free upkeep on their turn and experience based on round number
function vortex_intervention_army_manager()
	core:add_listener(
		"intervention_upkeep_monitor",
		"FactionTurnStart",
		function(context)
			return context:faction():name():find("_intervention");
		end,
		function(context)
			local character_list = context:faction():character_list();
			
			for i = 0, character_list:num_items() - 1 do
				local current_char = character_list:item_at(i);
				
				if current_char:has_military_force() then
					local cqi = current_char:cqi();
					
					cm:remove_effect_bundle_from_characters_force("wh_main_bundle_military_upkeep_free_force", cqi);
					cm:apply_effect_bundle_to_characters_force("wh_main_bundle_military_upkeep_free_force", cqi, 0, true);
					
					if current_char:rank() == 1 then
						cm:add_agent_experience(cm:char_lookup_str(cqi), 300 * cm:model():turn_number());
					end;
				end;
			end;
		end,
		true
	);
end;

-- get the ritual stage from the key
function vortex_get_ritual_stage(ritual_key)
	if ritual_key:find("_1_") then
		return 1;
	elseif ritual_key:find("_2_") then
		return 2;
	elseif ritual_key:find("_3_") then
		return 3;
	elseif ritual_key:find("_4_") then
		return 4;
	elseif ritual_key:find("_5_") then
		return 5;
	else
		script_error("ERROR: vortex_get_ritual_stage() called, but ritual key " .. ritual_key .. " is not a known vortex ritual key!");
		return false;
	end;
end;

-- monitor ritual sites for being lost, then show event
function vortex_setup_active_ritual_site_event_listeners()
	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		local current_human_faction_name = human_factions[i];
		local current_human_faction = cm:get_faction(current_human_faction_name);
		
		if current_human_faction:has_rituals() then
			local active_rituals = current_human_faction:rituals():active_rituals();
			
			if not active_rituals:is_empty() then
				-- this human faction has an active ritual, start monitoring the ritual sites
				vortex_setup_ritual_site_event_listeners(current_human_faction_name, active_rituals:item_at(0):ritual_sites());
			end;
		end;
	end;
end;

function vortex_setup_ritual_site_event_listeners(faction_name, ritual_sites)
	for i = 0, ritual_sites:num_items() - 1 do
		local current_ritual_site = ritual_sites:item_at(i);
		local current_ritual_site_name = current_ritual_site:name();
		
		core:add_listener(
			"ritual_site_razed_" .. current_ritual_site_name,
			"CharacterRazedSettlement",
			function(context)
				return context:character():has_region() and context:character():region():name() == current_ritual_site_name;
			end,
			function()
				vortex_show_ritual_site_event(faction_name, current_ritual_site_name);
			end,
			false
		);
		
		core:add_listener(
			"ritual_site_occupied_" .. current_ritual_site_name,
			"GarrisonOccupiedEvent",
			function(context)
				local character = context:character();
				
				return character:region():name() == current_ritual_site_name;
			end,
			function(context)
				local recaptured = false;
				
				if context:character():faction():name() == faction_name then
					recaptured = true;
				end;
				
				vortex_show_ritual_site_event(faction_name, current_ritual_site_name, recaptured);
			end,
			false
		);
	end;
end;

function vortex_show_ritual_site_event(faction_name, region_name, recaptured)	
	local faction = cm:get_faction(faction_name);
	local region = cm:get_region(region_name);
	
	local culture = vortex_get_culture_prefix(faction:culture());
	
	local primary_detail = "event_feed_strings_text_wh2_event_feed_string_scripted_event_ritual_site_lost_primary_detail";
	local secondary_detail = "event_feed_strings_text_wh2_event_feed_string_scripted_event_ritual_site_lost_secondary_detail";
	
	if recaptured then
		id = id + 10;
		primary_detail = "event_feed_strings_text_wh2_event_feed_string_scripted_event_ritual_site_recaptured_primary_detail";
		secondary_detail = "event_feed_strings_text_wh2_event_feed_string_scripted_event_ritual_site_recaptured_secondary_detail";
	end;
	
	local settlement = region:settlement();
	
	cm:show_message_event_located(
		faction:name(),
		primary_detail,
		"regions_onscreen_" .. region:name(),
		secondary_detail,
		settlement:logical_position_x(),
		settlement:logical_position_y(),
		true,
		vortex_get_event_pic_id(830, culture)
	);
end;

-- the ritual has completed, clear monitors for losing ritual sites
function vortex_remove_ritual_site_event_listeners(ritual_sites)
	for i = 0, ritual_sites:num_items() - 1 do
		local current_ritual_site_name = ritual_sites:item_at(i):name();
		
		core:remove_listener("ritual_site_razed_" .. current_ritual_site_name);
		
		core:remove_listener("ritual_site_occupied_" .. current_ritual_site_name);
	end;
end;

function vortex_complete_campaign(value)
	if value then		
		cm:disable_event_feed_events(true, "", "", "faction_campaign_victory_objective_complete");
	else
		cm:disable_event_feed_events(true, "", "", "faction_event_mission_aborted");
	end;
	
	local campaign_type = cm:model():campaign_type();
	
	if campaign_type == 0 then
		cm:complete_scripted_mission_objective("wh_main_long_victory", "final_battle_condition", value);
		cm:complete_scripted_mission_objective("wh2_main_vor_domination_victory", "domination", value);
	elseif campaign_type == 4 then
		cm:complete_scripted_mission_objective("wh_main_mp_coop_victory", "final_battle_condition", value);
	else
		cm:complete_scripted_mission_objective("wh_main_mp_versus_victory", "final_battle_condition", value);
	end;
end;

-- if an ai secondary faction confederates the primary faction, the diplomatic standing effect bundle is transferred over
function vortex_ai_confederation_listener()
	local effect_bundle = "wh2_main_ritual_vortex_";
	
	core:add_listener(
		"vortex_ai_confederation_listener",
		"FactionJoinsConfederation",
		true,
		function(context)
			local culture = vortex_get_culture_prefix(context:confederation():culture());
			
			-- there are 5 possible effect bundles to check
			for i = 1, 5 do
				local effect_bundle_test = effect_bundle .. i .. "_" .. culture;
				
				if context:faction():has_effect_bundle(effect_bundle_test) then
					cm:apply_effect_bundle(effect_bundle_test, context:confederation():name(), 0);
				end;
			end;
		end,
		true
	);
end;

-- after ritual 4 is completed, force war between completer and other factions and do not allow peace between any playable factions of different cultures
-- after game is won, remove the peace restriction
function vortex_update_diplomatic_restrictions(performing_faction_name, should_reset)
	local save_value = cm:get_saved_value("vortex_update_diplomatic_restrictions");
	
	local faction_list = {
		"wh2_main_def_cult_of_pleasure",
		"wh2_main_def_naggarond",
		"wh2_main_hef_eataine",
		"wh2_main_hef_order_of_loremasters",
		"wh2_main_lzd_hexoatl",
		"wh2_main_lzd_last_defenders",
		"wh2_main_skv_clan_mors",
		"wh2_main_skv_clan_pestilens"
	};
	
	local performing_faction = cm:get_faction(performing_faction_name);
	local performing_faction_culture = performing_faction:culture();
	
	for i = 1, #faction_list do
		local current_faction_name = faction_list[i];
		local current_faction = cm:get_faction(current_faction_name);
		local current_faction_culture = current_faction:culture();
		
		if current_faction and not current_faction:is_dead() then
			if not should_reset and current_faction_name ~= performing_faction_name and current_faction_culture ~= performing_faction_culture then
				cm:force_declare_war(current_faction_name, performing_faction_name, false, false);
			end;
			
			for j = 1, #faction_list do
				local current_target_faction_name = faction_list[j];
				local current_target_faction = cm:get_faction(current_target_faction_name);
				
				if current_target_faction and current_faction_name ~= current_target_faction_name and current_faction_culture ~= current_target_faction:culture() then
					if not save_value then
						cm:force_diplomacy("faction:" .. current_faction_name, "faction:" .. current_target_faction_name, "peace", false, false, true);
					elseif should_reset then
						cm:force_diplomacy("faction:" .. current_faction_name, "faction:" .. current_target_faction_name, "peace", true, true, true);
					end;
				end;
			end;
		end;
	end;
	
	if not save_value then
		cm:set_saved_value("vortex_update_diplomatic_restrictions", true);
		
		if performing_faction:is_human() then
			cm:show_message_event(
				performing_faction_name,
				"event_feed_strings_text_wh2_event_feed_string_scripted_event_ritual_4_completed_primary_detail",
				"",
				"event_feed_strings_text_wh2_event_feed_string_scripted_event_ritual_4_completed_secondary_detail",
				true,
				vortex_get_event_pic_id(885, vortex_get_culture_prefix(performing_faction_culture))
			);
		end;
	end;
end;

function vortex_setup_comet_movie_listeners(faction_name)
	cm:add_turn_countdown_event(faction_name, 25, "ScriptEventCometMovieProgress_" .. faction_name, faction_name);
	
	core:add_listener(
		"comet_faction_turn_start_progress_" .. faction_name,
		"ScriptEventCometMovieProgress_" .. faction_name,
		true,
		function(context)
			local faction_name = context.string;
			local faction = cm:get_faction(faction_name);
			
			vortex_play_comet_movie(faction);
		end,
		false
	);
	
	core:add_listener(
		"comet_faction_turn_start_currency_" .. faction_name,
		"FactionTurnStart",
		function(context)
			local faction = context:faction();
			
			return faction:name() == faction_name and faction:pooled_resource("wh2_main_ritual_currency"):value() >= 5000;
		end,
		function(context)
			vortex_play_comet_movie(context:faction());
		end,
		false
	);
end;

function vortex_play_comet_movie(faction)
	local faction_name = faction:name();
	
	core:remove_listener("comet_faction_turn_start_progress_" .. faction_name);
	core:remove_listener("comet_faction_turn_start_currency_" .. faction_name);
	
	if not cm:get_saved_value("comet_movie_played_" .. faction_name) then
		cm:set_saved_value("comet_movie_played_" .. faction_name, true)
		
		vortex_play_movie(faction, "comet");
	end;
end;

-- reinstates any monitors for when a faction performing a ritual and is killed to kill incursion armies
function vortex_setup_active_incusion_death_monitors()
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);

		if current_faction:has_rituals() then
			local active_rituals = current_faction:rituals():active_rituals()
			
			if active_rituals:num_items() > 0 and current_faction:culture():find("wh2_main_") then
				local culture_prefix = vortex_get_culture_prefix(current_faction:culture());
				
				local incursion_factions = {
					"wh2_main_chs_chaos_incursion_" .. culture_prefix,
					"wh2_main_nor_hung_incursion_" .. culture_prefix,
					"wh2_main_skv_unknown_clan_" .. culture_prefix
				};

				for j = 1, #incursion_factions do
					if not cm:get_faction(incursion_factions[j]):is_dead() then
						vortex_incursion_death_monitor(incursion_factions[j], current_faction:name());
					end;
				end;
			end;
		end;
	end;
	
	-- if an intervention or incursion faction ends their turn without any enemies, then we kill them as well
	core:add_listener(
		"kill_inactive_intervention_and_incursion_factions",
		"FactionTurnEnd",
		function(context)
			local faction = context:faction();
			local faction_name = faction:name();
			
			local intervention_and_incursion_factions = {
				"wh2_main_chs_chaos_incursion_",
				"wh2_main_nor_hung_incursion_",
				"wh2_main_skv_unknown_clan_",
				"_intervention"
			};
			
			for i = 1, #intervention_and_incursion_factions do
				if faction_name:find(intervention_and_incursion_factions[i]) and not faction:at_war() then
					return true;
				end;
			end;
		end,
		function(context)
			kill_incursion_faction(context:faction():character_list());
		end,
		true
	);
end;

-- monitors for a target faction dying, if it does then kill all incursion armies
function vortex_incursion_death_monitor(incursion_faction_name, target_faction_name)
	core:add_listener(
		"incursion_death_monitor_" .. incursion_faction_name .. "_" .. target_faction_name,
		"FactionTurnStart",
		function(context)
			return context:faction():name() == incursion_faction_name and cm:get_faction(target_faction_name):is_dead();
		end,
		function()
			core:remove_listener("incursion_death_monitor_" .. incursion_faction_name .. "_" .. target_faction_name);
			
			kill_incursion_faction(cm:get_faction(incursion_faction_name):character_list());
		end,
		true
	);
end;

function kill_incursion_faction(char_list)
	for i = 0, char_list:num_items() - 1 do
		cm:kill_character(char_list:item_at(i):command_queue_index(), true, true);
	end;
end;

function vortex_get_event_pic_id(id, culture)
	if culture == "def" then
		id = id + 1;
	elseif culture == "lzd" then
		id = id + 2;
	elseif culture == "skv" then
		id = id + 3;
	end;
	
	return id;
end;

function vortex_lock_ritual_chains()
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if current_faction:has_rituals() and current_faction:culture():find("wh2_main_") then
			cm:lock_ritual_chain(current_faction, "wh2_main_ritual_vortex_" .. vortex_get_culture_prefix(current_faction:culture()));
		end;
	end;
end;
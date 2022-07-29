thorek = {}

thorek.artifact_parts = {
	---one list per campaign
	main_warhammer = {
		--- artifact pooled resource key = region key, bundle key
		dwf_thorek_artifact_part_1a = {region = "wh2_main_southlands_jungle_golden_tower_of_the_gods", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_1a"},
		dwf_thorek_artifact_part_1b = {region = "wh2_main_charnel_valley_karag_orrud", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_1b"},
		dwf_thorek_artifact_part_2a = {region = "wh2_main_devils_backbone_lahmia", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_2a"},
		dwf_thorek_artifact_part_2b = {region = "wh2_main_northern_dark_lands_silver_pinnacle", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_2b"},
		dwf_thorek_artifact_part_3a = {region = "wh_main_blightwater_misty_mountain", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_3a"},
		dwf_thorek_artifact_part_3b = {region = "wh_main_blightwater_karak_azgal", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_3b"},
		dwf_thorek_artifact_part_4a = {region = "wh_main_southern_grey_mountains_karak_azgaraz", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_4a"},
		dwf_thorek_artifact_part_4b = {region = "wh2_main_the_wolf_lands_mount_silverspear", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_4b"},
		dwf_thorek_artifact_part_5a = {region = "wh_main_rib_peaks_mount_gunbad", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_5a"},
		dwf_thorek_artifact_part_5b = {region = "wh_main_death_pass_karak_drazh", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_5b"},
		dwf_thorek_artifact_part_6a = {region = "wh2_main_atalan_mountains_vulture_mountain", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_6a"},
		dwf_thorek_artifact_part_6b = {region = "wh_main_southern_badlands_galbaraz", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_6b"},
		dwf_thorek_artifact_part_7a = {region = "wh_main_zhufbar_karag_dromar", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_7a"},
		dwf_thorek_artifact_part_7b = {region = "wh_main_eastern_badlands_valayas_sorrow", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_7b"},
		dwf_thorek_artifact_part_8a = {region = "wh_main_gianthome_mountains_kraka_drak", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_8a"},
		dwf_thorek_artifact_part_8b = {region = "wh_main_northern_worlds_edge_mountains_karak_ungor", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_8b"},
	},
	wh2_main_great_vortex = {
		dwf_thorek_artifact_part_1a = {region = "wh2_main_vor_the_lost_valleys_subatuun", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_1a"},
		dwf_thorek_artifact_part_1b = {region = "wh2_main_vor_river_qurveza_axlotl", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_1b"},
		dwf_thorek_artifact_part_2a = {region = "wh2_main_vor_copper_desert_the_golden_colossus", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_2a"},
		dwf_thorek_artifact_part_2b = {region = "wh2_main_vor_the_dragon_isles_the_blood_hall", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_2b"},
		dwf_thorek_artifact_part_3a = {region = "wh2_main_vor_central_spine_of_sotek_chiquibol", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_3a"},
		dwf_thorek_artifact_part_3b = {region = "wh2_main_vor_southern_spine_of_sotek_mine_of_the_bearded_skulls", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_3b"},
		dwf_thorek_artifact_part_4a = {region = "wh2_main_vor_jungles_of_green_mist_spektazuma", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_4a"},
		dwf_thorek_artifact_part_4b = {region = "wh2_main_vor_northern_spine_of_sotek_cavern_of_the_mlexigaur", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_4b"},
		dwf_thorek_artifact_part_5a = {region = "wh2_main_vor_culchan_plains_chupayotl", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_5a"},
		dwf_thorek_artifact_part_5b = {region = "wh2_main_vor_volcanic_islands_fuming_serpent", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_5b"},
		dwf_thorek_artifact_part_6a = {region = "wh2_main_vor_cobra_pass_vulture_mountain", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_6a"},
		dwf_thorek_artifact_part_6b = {region = "wh2_main_vor_the_vampire_coast_the_awakening", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_6b"},
		dwf_thorek_artifact_part_7a = {region = "wh2_main_vor_settlers_coast_skeggi", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_7a"},
		dwf_thorek_artifact_part_7b = {region = "wh2_main_vor_lustria_glade", bundle = "wh2_dlc17_effect_bundle_thorek_artifact_part_7b"},
	}
}
thorek.already_looted = {}
thorek.artifact_piece_vfx_key = "scripted_effect18";
thorek.thorek_faction_key = "wh2_dlc17_dwf_thorek_ironbrow"
thorek.artifact_base_string = "dwf_thorek_artifact_part_*" --- db keys for thorek's artifact part pooled resources need to follow this format
thorek.artifact_resource_factor = "wh2_main_resource_factor_missions"
thorek.rituals_completed = 0
thorek.skaven_attacks_occured = 0
thorek.attack_queue = {}
thorek.attack_configs = {
	wh2_main_great_vortex = {
		{ 
			enemy = "thorek_enemy_skryre_ektrik", enemy_count = 1, units = 15, mission = "wh2_dlc17_dwf_thorek_vortex_objective_1", 
			payload = "effect_bundle{bundle_key wh2_dlc17_payload_thorek_vortex_objective_1;turns 1;}"
		},
		{ 
			enemy = "thorek_enemy_skryre_vrrtkin", enemy_count = 2, units = 20, mission = "wh2_dlc17_dwf_thorek_vortex_objective_2", 
			payload = "effect_bundle{bundle_key wh2_dlc17_payload_thorek_vortex_objective_2;turns 1;}"
		},
		{
			enemy = "thorek_enemy_eshin", enemy_count = 3, units = 20, mission = "wh2_dlc17_dwf_thorek_vortex_objective_3", 
			payload = "effect_bundle{bundle_key wh2_dlc17_payload_thorek_vortex_objective_3;turns 1;}"
		},
		{
			-- intentionally blank for 4th artefact completed
		},
		{ 
			faction = "wh2_dlc17_dwf_thorek_ironbrow", mission = "wh2_dlc17_dwf_thorek_final_battle_lost_vault", 
			is_quest_battle_mission = true 	-- for triggering a specific scripted_battle mission then use is_quest_battle_mission = true
		}
	},
	main_warhammer = {	
	}
}

-- Various scripted objective configurations relating to 'you need to get x artefacts to tick this box' missions, which are used in a few different places.
thorek.scripted_objectives = {
	-- Scripted objectives used in Chapter Objectives.
	{ mission_key = "wh2_dlc17_objective_thorek_02", objective_key = "artefacts_crafted_chapter_objective_0", artefacts_needed = 1 },
	{ mission_key = "wh2_dlc17_objective_thorek_04", objective_key = "artefacts_crafted_chapter_objective_1", artefacts_needed = 5 },
	-- Scripted objectives used in ME Victory Conditions.
	{ mission_key = "wh_main_short_victory", objective_key = "artefacts_crafted_victory_objective_me_0", artefacts_needed = 5 },
	{ mission_key = "wh_main_long_victory", objective_key = "artefacts_crafted_victory_objective_me_1", artefacts_needed = 8 },
	{ mission_key = "wh_main_victory_type_mp_coop", objective_key = "artefacts_crafted_victory_objective_me_2", artefacts_needed = 8 },
	-- Scripted objectives used in Vortex Victory Conditions.
	{ mission_key = "wh_main_long_victory", objective_key = "artefacts_crafted_victory_objective_vortex_0", artefacts_needed = 5 },
	{ mission_key = "wh2_main_vor_domination_victory", objective_key = "artefacts_crafted_victory_objective_vortex_1", artefacts_needed = 8 },
	{ mission_key = "wh_main_victory_type_mp_coop", objective_key = "artefacts_crafted_victory_objective_vortex_2", artefacts_needed = 8 },
}


local campaign_key = cm:get_campaign_name()

function thorek:initialise()
	local thorek_interface = cm:get_faction(self.thorek_faction_key)

	if not thorek_interface or not thorek_interface:is_human() then
		return
	end

	out("###Setting up Thorek Listeners###")

	if cm:is_new_game() then
		self:apply_region_vfx()
	end

	self:setup_region_capture_listener()
	self:setup_resource_click_listener()
	self:setup_faction_turn_start_listener()
	self:setup_positive_diplomatic_event_listener()
	self:setup_region_faction_change_event_listener()
	setup_thorek_crafting_ritual_complete_listener()

	thorek_SetupArmies();
end


function thorek:setup_region_capture_listener()
	core:add_listener(
		"CharacterPerformsSettlementOccupationDecisionThorek",
		"CharacterPerformsSettlementOccupationDecision",
		function(context)
			return context:character():faction():name() == self.thorek_faction_key and context:occupation_decision() ~= "596"
		end,
		function(context)
			local region_key = context:garrison_residence():region():name()
			local artifact_part_key = self:get_artifact_part_from_region(region_key)

			if artifact_part_key then
				self:award_artifact_part(artifact_part_key, 1)

				local residence_cqi = context:garrison_residence():command_queue_index()
				cm:remove_garrison_residence_vfx(residence_cqi, self.artifact_piece_vfx_key)
			end
		end,
	true)
end

function thorek:setup_positive_diplomatic_event_listener()
	core:add_listener(
		"Thorek_PositiveDiplomaticEvent",
		"PositiveDiplomaticEvent",
		function(context)
			local proposer = context:proposer():name()
			local recipient = context:recipient():name()

			if recipient == self.thorek_faction_key or proposer == self.thorek_faction_key then
				return true
			end
		end,
		function(context) 

			if context:is_military_alliance() or context:is_vassalage() then
				local other_faction

				if context:proposer():name() == self.thorek_faction_key then
					other_faction = context:recipient():name()
				else
					other_faction = context:proposer():name()	
				end
				for k, v in pairs(self.artifact_parts[campaign_key]) do
					if cm:is_region_owned_by_faction(v.region, other_faction) then
						self:award_artifact_part(k, 1)
						local residence_cqi = cm:get_region(v.region):garrison_residence():command_queue_index()
						cm:remove_garrison_residence_vfx(residence_cqi, self.artifact_piece_vfx_key);
					end	
				end
				-- Nakai specific fix, alliance with Nakai also does a check for their vassal
				if other_faction == "wh2_dlc13_lzd_spirits_of_the_jungle" then
					for k, v in pairs(self.artifact_parts[campaign_key]) do
						if cm:is_region_owned_by_faction(v.region, "wh2_dlc13_lzd_defenders_of_the_great_plan") then
							self:award_artifact_part(k, 1)
							local residence_cqi = cm:get_region(v.region):garrison_residence():command_queue_index()
							cm:remove_garrison_residence_vfx(residence_cqi, self.artifact_piece_vfx_key);
						end	
					end
				end
			end
		end,
		true
	);
end

function thorek:setup_region_faction_change_event_listener()
	core:add_listener(
		"Thorek_RegionFactionChangeEvent",
		"RegionFactionChangeEvent",
		true,
		function(context)
			local region = context:region();
			local region_key = region:name();
			local artifact_part_key = self:get_artifact_part_from_region(region_key);

			if artifact_part_key then
				local owner = region:owning_faction();
				if (owner:name() == self.thorek_faction_key or owner:is_ally_vassal_or_client_state_of(cm:get_faction(self.thorek_faction_key))) then
					self:award_artifact_part(artifact_part_key, 1);
					
					cm:remove_garrison_residence_vfx(region:garrison_residence():command_queue_index(), self.artifact_piece_vfx_key);
				end
				if not self.already_looted[artifact_part_key] then
					cm:apply_effect_bundle_to_region(self.artifact_parts[campaign_key][artifact_part_key].bundle, region_key, 0)
				end			
			end
		end,
		true
	);
end

function thorek:setup_resource_click_listener()
	core:add_listener(
		"ThorekArtifactPieceLClickUp",
		"ComponentLClickUp",
		function(context)
			return string.match(context.string, self.artifact_base_string)
		end,
		function(context)
			local crafting_panel_close = find_uicomponent("mortuary_cult", "button_ok")

			if crafting_panel_close then
				crafting_panel_close:SimulateLClick()
			else
				script_error("thorek:setup_resource_click_listener() is trying to close the crafting panel when it's not open, how has this happened?")
			end

			self:pan_to_artifact_location(context.string)

			if not self.already_looted[context.string] then
				cm:trigger_campaign_vo("Play_wh2_dlc17_dwf_thorek_ironbrow_vault_unfound", "", 0)
			end
		end,
		true
	);
end

function thorek:setup_faction_turn_start_listener()
	core:add_listener(
		"thorek_FactionTurnStart",
		"ScriptEventHumanFactionTurnStart",
		function(context)
			return context:faction():name() == self.thorek_faction_key
		end,
		function(context)
			thorek_FactionTurnStart(context:faction());
		end,
		true
	);
end

function thorek:pan_to_artifact_location(artifact_part_key)
	local region_interface = thorek:get_region_from_artifact_part(artifact_part_key)

	if region_interface then
		cm:scroll_camera_from_current(true,3, {region_interface:settlement():display_position_x(), region_interface:settlement():display_position_y(), 10.5, 0.0, 6.8})
	end
end

function thorek:apply_region_vfx()
	for artifact_key, artifact_part_info in pairs(self.artifact_parts[campaign_key]) do
		local region_key = artifact_part_info.region
		local residence_cqi = cm:get_region(region_key):garrison_residence():command_queue_index()

		cm:add_garrison_residence_vfx(residence_cqi, self.artifact_piece_vfx_key, true);
		-- also applys effect bundle to display artefact part icon on region
		cm:apply_effect_bundle_to_region(artifact_part_info.bundle, region_key, 0)
	end
end


function thorek:get_artifact_part_from_region(region_key)
	for artifact_part_key, artifact_part_info in pairs(self.artifact_parts[campaign_key]) do
		if artifact_part_info.region == region_key then
			return artifact_part_key
		end
	end
end

function thorek:get_region_from_artifact_part(pooled_resource_key)
	return cm:get_region(self.artifact_parts[campaign_key][pooled_resource_key].region)
end

function thorek:award_artifact_part(artifact_part_key, amount)
	if not self.already_looted[artifact_part_key] then

		cm:faction_add_pooled_resource(self.thorek_faction_key, artifact_part_key, self.artifact_resource_factor, amount)
		self.already_looted[artifact_part_key] = true

		local artifact = self.artifact_parts[campaign_key][artifact_part_key]
		cm:remove_effect_bundle_from_region(artifact.bundle, artifact.region)
		
		cm:show_message_event(self.thorek_faction_key,"event_feed_strings_text_wh2_dlc17_event_feed_string_thorek_artifact_found_title","pooled_resources_display_name_"..artifact_part_key, "event_feed_strings_text_wh2_dlc17_event_feed_string_thorek_artifact_found_secondary_detail",true, 1701)
		--trigger event for artefact part being awarded
		core:trigger_event("ScriptEventForgeArtefactPartReceived")

		local artifact_part_pair_key = string.sub(artifact_part_key, 1, string.len(artifact_part_key)-1);
		if self.already_looted[artifact_part_pair_key.."a"] and self.already_looted[artifact_part_pair_key .. "b"] then
			core:trigger_event("ScriptEventForgeArtefactPair")
		end
	end
end


-- Ghost Thane Spawn and rituals completed 
function setup_thorek_crafting_ritual_complete_listener()
	core:add_listener(
		"thorek_crafting_ritual",
		"RitualCompletedEvent",
		function(context)
			return context:ritual():ritual_category() == "CRAFTING_RITUAL";
		end,
		function(context)
			local ritual = context:ritual();
			local ritual_key = ritual:ritual_key();
			local faction = context:performing_faction();
			local faction_cqi = context:performing_faction():command_queue_index()
			local faction_name = faction:name();
			
			--Any rituals beginning with this prefix will be considered a thorek artifact ritual.
			thorek.ritual_prefix = "wh2_dlc17_dwf_ritual_thorek_artifact_"
			thorek.ghost_thane_ritual = thorek.ritual_prefix .. "2"
			
			if string.find(ritual_key, thorek.ritual_prefix) == 1 then
				thorek.rituals_completed = thorek.rituals_completed + 1		   		 	-- increment rituals_completed by 1

				for s = 1, #thorek.scripted_objectives do
					scripted_objective = thorek.scripted_objectives[s]
					if thorek.rituals_completed == scripted_objective.artefacts_needed then
						cm:complete_scripted_mission_objective(scripted_objective.mission_key, scripted_objective.objective_key, true);
					end
				end

				if thorek.attack_configs[campaign_key][thorek.rituals_completed] and next(thorek.attack_configs[campaign_key][thorek.rituals_completed]) then
					thorek:push_skaven_attack(thorek.attack_configs[campaign_key][thorek.rituals_completed])	    		-- push a skaven attack onto the queue
				end

				if ritual_key == thorek.ghost_thane_ritual then
					cm:spawn_unique_agent(faction_cqi, "wh2_dlc17_dwf_thane_ghost_artifact",true)	-- spawn a spooky ghost thane  	
				end

				if thorek.rituals_completed == 8 then
					core:trigger_event("ScriptEventArtefactsForgedAll")
				elseif thorek.rituals_completed >= 3 then
					core:trigger_event("ScriptEventArtefactsForgedThree")
				else
					core:trigger_event("ScriptEventArtefactsForgedOne")
				end
			end	
		end,
		true
	);
end

function thorek:push_skaven_attack(attack_config)
	if attack_config == nil then 
		return 
	end
	table.insert(self.attack_queue, attack_config)
end

function thorek:pop_skaven_attack()
	first_item = self.attack_queue[1]
	self.attack_queue[1] = nil
	for i = 1, #self.attack_queue - 1 do
		self.attack_queue[i] = self.attack_queue[i + 1]
		self.attack_queue[i + 1] = nil
	end
	return first_item
end

function thorek_FactionTurnStart(thorek_faction)
	local thorek_faction = cm:model():world():faction_by_key(thorek.thorek_faction_key);

	if #thorek.attack_queue > 0 then
		next_attack = thorek:pop_skaven_attack()
		if not next_attack.is_quest_battle_mission then 
			thorek:SpawnThorekEnemy(thorek_faction, next_attack.enemy, next_attack.enemy_count, next_attack.units, next_attack.mission, next_attack.payload) 
		else
			cm:trigger_mission(next_attack.faction, next_attack.mission, true)
		end	
	end	
end

-- Artifact Hunter intervention armies
function thorek:SpawnThorekEnemy(faction, enemy, enemy_count, units, mission, payload)
	local faction_key = faction:name();
	local thorek_leader = faction:faction_leader();
	local thorek_cqi = thorek_leader:command_queue_index();
	local mf_list = faction:military_force_list();
	local target_mf = nil;
	local pos_x, pos_y;
	local spawn_was_successful = false;

	for i = 1, enemy_count do
		local unit_count = units;
		local spawn_units, enemy_faction = random_army_manager:generate_force(enemy, unit_count, false);
		
		if thorek_leader:is_wounded() then
			-- if faction leader is wounded then find a different force
			for i = 0, mf_list:num_items() - 1 do
				force = mf_list:item_at(i);
				target_mf = force;
				local force_character = target_mf:general_character():command_queue_index();
				pos_x, pos_y = cm:find_valid_spawn_location_for_character_from_character(enemy_faction, "character_cqi:"..force_character, false, 50);
			end
			-- if there are still no suitable characters to spawn at, then spawn at region instead
			if target_mf == nil then
				local region_list = faction:region_list();
				for i = 0, region_list:num_items() - 1 do
					local region = region_list:item_at(i);
					pos_x, pos_y = cm:find_valid_spawn_location_for_character_from_settlement(enemy_faction, region, false, false, 20);
					return;
				end
			end
		else
			pos_x, pos_y = cm:find_valid_spawn_location_for_character_from_character(enemy_faction, "character_cqi:"..thorek_cqi, false, 50);
		end
		
		if pos_x == -1 then
			pos_x, pos_y = cm:find_valid_spawn_location_for_character_from_character(enemy_faction, "character_cqi:"..thorek_cqi, false);
		end

		if pos_x > -1 then
			if i == 1 then
				local objective_invasion = invasion_manager:new_invasion(mission.."_"..i, enemy_faction, spawn_units, {pos_x, pos_y});
				objective_invasion:set_target("CHARACTER", thorek_cqi, faction_key);
				objective_invasion:apply_effect("wh2_dlc14_bundle_objective_invasion", -1);
				objective_invasion.mission_key = mission;

				objective_invasion:start_invasion(
				function(self)
					local force = self:get_force();
					local force_cqi = force:command_queue_index();

					local mm = mission_manager:new(thorek.thorek_faction_key, self.mission_key);
					mm:set_mission_issuer("CLAN_ELDERS");
					mm:add_new_objective("ENGAGE_FORCE");
					mm:add_condition("cqi "..force_cqi);
					mm:add_condition("requires_victory");
					mm:set_turn_limit(0);
					mm:set_should_whitelist(false);
					mm:add_payload(payload);
					mm:trigger();
				end, true, false, false);
			else
				local objective_invasion = invasion_manager:new_invasion(mission.."_"..i, enemy_faction, spawn_units, {pos_x, pos_y});
				objective_invasion:set_target("CHARACTER", thorek_cqi, faction_key);
				objective_invasion:apply_effect("wh2_dlc14_bundle_objective_invasion", -1);
				objective_invasion:start_invasion(nil, true, false, false);
			end
			spawn_was_successful = true;
		else
			script_error("ERROR: Trying to spawn a Vortex mission for thorek, no valid position for enemy army");
		end
	end
	if spawn_was_successful then 
		self.skaven_attacks_occured = self.skaven_attacks_occured + 1 
	end
end


function thorek_SetupArmies()
		
	random_army_manager:new_force("thorek_enemy_skryre_ektrik");
	random_army_manager:set_faction("thorek_enemy_skryre_ektrik", "wh2_main_skv_skaven_qb3");
	random_army_manager:add_mandatory_unit("thorek_enemy_skryre_ektrik", "wh2_main_skv_art_warp_lightning_cannon", 1);
	random_army_manager:add_mandatory_unit("thorek_enemy_skryre_ektrik", "wh2_dlc12_skv_inf_ratling_gun_0", 1);
	random_army_manager:add_mandatory_unit("thorek_enemy_skryre_ektrik", "wh2_main_skv_veh_doomwheel", 2);
	random_army_manager:add_mandatory_unit("thorek_enemy_skryre_ektrik", "wh2_main_skv_mon_rat_ogres", 1);
	random_army_manager:add_unit("thorek_enemy_skryre_ektrik", "wh2_dlc12_skv_inf_ratling_gun_0", 1);	
	random_army_manager:add_unit("thorek_enemy_skryre_ektrik", "wh2_dlc12_skv_inf_warplock_jezzails_0", 1);
	random_army_manager:add_unit("thorek_enemy_skryre_ektrik", "wh2_dlc16_skv_mon_wolf_rats_0", 2); 
	random_army_manager:add_unit("thorek_enemy_skryre_ektrik", "wh2_main_skv_inf_clanrat_spearmen_0", 2); 
	random_army_manager:add_unit("thorek_enemy_skryre_ektrik", "wh2_main_skv_inf_clanrats_0", 2);	
	random_army_manager:add_unit("thorek_enemy_skryre_ektrik", "wh2_main_skv_inf_clanrats_1", 2); 
	random_army_manager:add_unit("thorek_enemy_skryre_ektrik", "wh2_main_skv_inf_clanrat_spearmen_1", 2); 

	random_army_manager:new_force("thorek_enemy_skryre_vrrtkin");
	random_army_manager:set_faction("thorek_enemy_skryre_vrrtkin", "wh2_main_skv_skaven_qb3");
	random_army_manager:add_mandatory_unit("thorek_enemy_skryre_vrrtkin", "wh2_main_skv_art_warp_lightning_cannon", 2); 
	random_army_manager:add_mandatory_unit("thorek_enemy_skryre_vrrtkin", "wh2_dlc14_skv_inf_poison_wind_mortar_0", 1);
	random_army_manager:add_mandatory_unit("thorek_enemy_skryre_vrrtkin", "wh2_main_skv_veh_doomwheel", 1);
	random_army_manager:add_mandatory_unit("thorek_enemy_skryre_vrrtkin", "wh2_dlc12_skv_veh_doom_flayer_0", 2);
	random_army_manager:add_mandatory_unit("thorek_enemy_skryre_vrrtkin", "wh2_dlc12_skv_inf_warplock_jezzails_0", 1);
	random_army_manager:add_unit("thorek_enemy_skryre_vrrtkin", "wh2_dlc12_skv_inf_ratling_gun_0", 1);	
	random_army_manager:add_unit("thorek_enemy_skryre_vrrtkin", "wh2_main_skv_inf_warpfire_thrower", 1);
	random_army_manager:add_unit("thorek_enemy_skryre_vrrtkin", "wh2_main_skv_inf_clanrat_spearmen_0", 2); 
	random_army_manager:add_unit("thorek_enemy_skryre_vrrtkin", "wh2_main_skv_inf_clanrats_0", 2);	
	random_army_manager:add_unit("thorek_enemy_skryre_vrrtkin", "wh2_main_skv_inf_clanrats_1", 2); 
	random_army_manager:add_unit("thorek_enemy_skryre_vrrtkin", "wh2_main_skv_inf_clanrat_spearmen_1", 2); 
	 
	random_army_manager:new_force("thorek_enemy_eshin");
	random_army_manager:set_faction("thorek_enemy_eshin", "wh2_main_skv_skaven_qb3");
	random_army_manager:add_mandatory_unit("thorek_enemy_eshin", "wh2_dlc14_skv_inf_eshin_triads_0", 4);
	random_army_manager:add_mandatory_unit("thorek_enemy_eshin", "wh2_main_skv_art_warp_lightning_cannon", 2);
	random_army_manager:add_mandatory_unit("thorek_enemy_eshin", "wh2_dlc16_skv_mon_rat_ogre_mutant", 1);
	random_army_manager:add_mandatory_unit("thorek_enemy_eshin", "wh2_dlc14_skv_inf_warp_grinder_0", 1);
	random_army_manager:add_unit("thorek_enemy_eshin", "wh2_dlc14_skv_inf_poison_wind_mortar_0", 1);	
	random_army_manager:add_unit("thorek_enemy_eshin", "wh2_main_skv_inf_death_globe_bombardiers", 1);
	random_army_manager:add_unit("thorek_enemy_eshin", "wh2_main_skv_inf_death_runners_0", 2); 
	random_army_manager:add_unit("thorek_enemy_eshin", "wh2_main_skv_inf_gutter_runner_slingers_1", 2);	
	random_army_manager:add_unit("thorek_enemy_eshin", "wh2_main_skv_inf_gutter_runners_1", 2); 
	random_army_manager:add_unit("thorek_enemy_eshin", "wh2_main_skv_inf_stormvermin_1", 2); 
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("artifact_objectives", thorek.rituals_completed, context);
		cm:save_named_value("artifact_hunters", thorek.skaven_attacks_occured, context);
		cm:save_named_value("attack_queue", thorek.attack_queue, context);
		cm:save_named_value("already_looted", thorek.already_looted, context);
	end
);
cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			thorek.rituals_completed = cm:load_named_value("artifact_objectives", thorek.rituals_completed, context);
			thorek.skaven_attacks_occured = cm:load_named_value("artifact_hunters", thorek.skaven_attacks_occured, context);
			thorek.attack_queue = cm:load_named_value("attack_queue", thorek.attack_queue, context);
			thorek.already_looted = cm:load_named_value("already_looted", thorek.already_looted, context);
		end
	end
);
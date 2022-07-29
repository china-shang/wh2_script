
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	Custom ui listeners
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

prepend_settlement_str = "settlement:";

-- outputs click information to the Lua - UI Script tab
output_uicomponent_on_click();

-- create some campaign helper objects
infotext = get_infotext_manager();
objectives = get_objectives_manager();
uim = cm:get_campaign_ui_manager();

-- attempt to check campaign documentation if we should
if core:is_tweaker_set("CHECK_CAMPAIGN_SCRIPT_DOCGEN") and vfs.exists("script/docgen/docgen_campaign_parser.lua") then
	require("script.docgen.docgen_campaign_parser");
end;

-- we don't save override states in WH, which means that if an override is locked and
-- the game is saved, it should be unlocked when the game is loaded again
uim:set_should_save_override_state(false);

cm:set_use_cinematic_borders_for_automated_cutscenes(false);

-- load in export_advice/export_triggers/etc
force_require("wh_campaign_experience_triggers");
-- this has to be run on script load as the first tick can be too late to apply
-- experience triggers and some other things post-battle
cm:add_pre_first_tick_callback(
	function()
		cm:load_exported_files("export_helpers");
		cm:load_exported_files("export_triggers");
		cm:load_exported_files("export_ancillaries");
		--cm:load_exported_files("export_experience");
	
		-- load the experience triggers
		setup_experience_triggers();
	end
);

intercontinental_diplomacy_turn = 70;

function setup_wh_campaign(exclude_battle_advice)

	out("setup_wh_campaign() called");
	
	out.inc_tab();
	
	-- start custom listeners for player actions
	-- these listeners usually trigger further events to notify external scripts (e.g. advice interventions) of player actions
	start_custom_listeners();
	
	-- monitor region corruption level, and apply attrition based on the %
	setup_region_corruption_monitor();
	
	-- add scripted building effects
	Add_Building_Effect_Listeners();
	
	-- load battle script whenever a battle is launched from this campaign (this activates advice)
	if not exclude_battle_advice then
		add_battle_script_override();
	end;

	-- monitor for Chaos razing a region, then apply Chaos corruption_monitor
	setup_chaos_raze_region_monitor();
	
	-- monitor for player confederation taking place
	start_confederation_listeners();
	
	sea_region_shroud_effect_listener();
	
	local local_faction = cm:get_local_faction_name(true);
	
	if local_faction and cm:get_faction(local_faction) then
		-- monitor for player recruiting new armies
		player_army_count_listener();
		
		-- enable movement for the player's faction if this is not a new game (just in case the player somehow saved in the middle of an intervention)
		if not cm:is_new_game() then
			cm:enable_movement_for_faction(local_faction);
		end;
	else
		out("Autorun running, not applying upkeep penalties for additional armies");
	end;
	
	-- monitor rebel armies, and give them siege equipment
	setup_rebel_army_siege_equipment_monitor();
	
	-- listen for blood pack incidents firing, then apply effects
	blood_pack_incidents_listener();
	
	-- high elf elven espionage
	elven_espionage_monitor();
	
	-- skaven menace below army ability
	menace_below_monitor();
	
	-- open geomantic web help page when geomantic web screen opened
	--show_geomantic_web_help_page_on_screen_open();
	
	-- show an event when player performs a hero action that targets ruins that are not skaven owned
	show_target_ruins_success_event_message();
	
	-- apply effect bundle when human beastmen make positive diplomatic treaty
	beastmen_positive_diplomatic_event_listener();
	
	add_intercontinental_diplomacy_listener();
	
	-- intercontinental diplomacy update
	local max_distance = cm:get_saved_value("intercontinental_diplomacy_available");
	
	if max_distance then
		update_international_diplomacy_listener(max_distance);
	end;
	
	GeneratedConstants:generate_constants()

	--- set-up any cross-campaign quest battle listeners
	qbh:initialise()

	-- AI Beastmen armies can get stuck in encampment stance attempting to
	-- replenish losses that they suffer from low army morale attrition
	-- Mitch, 04/07/16
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if not current_faction:is_human() and not current_faction:is_quest_battle_faction() then
			local culture = current_faction:culture();
			
			if culture == "wh_dlc03_bst_beastmen" and not current_faction:has_effect_bundle("wh_dlc03_low_morale_attrition_immunity") then
				cm:apply_effect_bundle("wh_dlc03_low_morale_attrition_immunity", current_faction:name(), 0);
			elseif culture == "wh_main_grn_greenskins" and not current_faction:has_effect_bundle("wh2_main_bundle_greenskin_animosity_bonus") then
				cm:apply_effect_bundle("wh2_main_bundle_greenskin_animosity_bonus", current_faction:name(), 0);
			end;
		end;
	end;
	
	out.dec_tab();
end;










function start_custom_listeners()

	local local_faction = cm:get_local_faction_name(true);
	
	-- don't start in multiplayer or autorun mode
	if cm:is_multiplayer() or not local_faction then
		return false;
	end;
	
	local ui_root = core:get_ui_root();

	-- custom event generators
	-- these listen for events and conditions to occur and then fire custom script events when they do. Doing this greatly 
	-- reduces the amount of work that the intervention system has to do (and the amount of output it generates)
	
	core:start_custom_event_generator("PanelOpenedCampaign", function(context) return context.string == "diplomacy_dropdown" end, "ScriptEventDiplomacyPanelOpened");
	
	-- ScriptEventPreBattlePanelOpened generated by campaign manager
	core:start_custom_event_generator("PanelClosedCampaign", function(context) return context.string == "popup_pre_battle" end, "ScriptEventPreBattlePanelClosed");
	
	core:start_custom_event_generator("PanelOpenedCampaign", function(context) return context.string == "popup_battle_results" end, "ScriptEventPostBattlePanelOpened");
	core:start_custom_event_generator("PanelClosedCampaign", function(context) return context.string == "popup_battle_results" end, "ScriptEventPostBattlePanelClosed");
	
	core:start_custom_event_generator("PanelOpenedCampaign", function(context) return context.string == "move_options" end, "ScriptEventMoveOptionsPanelOpened");
	
	core:start_custom_event_generator("PanelOpenedCampaign", function(context) return context.string == "appoint_new_general" end, "ScriptEventAppointNewGeneralPanelOpened");
	
	-- diplomacy button clicked
	core:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) return UIComponent(context.component) == find_uicomponent(ui_root, "faction_buttons_docker", "button_diplomacy") end, 
		"ScriptEventPlayerOpensDiplomacyPanel"
	);
	
	-- diplomacy button shortcut used
	core:start_custom_event_generator(
		"ShortcutPressed", 
		function(context) return context.string == "show_diplomacy" end, 
		"ScriptEventPlayerOpensDiplomacyPanel"
	);
		
	-- raise lord button clicked
	core:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) return UIComponent(context.component) == find_uicomponent(ui_root, "character_panel", "raise_forces_options", "button_raise") end, 
		"ScriptEventRaiseForceButtonClicked"
	);
	
	-- player settlement comes under siege
	core:start_custom_event_generator(
		"CharacterBesiegesSettlement",
		function(context) return context:region():owning_faction():name() == local_faction end,
		"ScriptEventPlayerBesieged",
		function(context) return context:region() end
	)
	
	core:start_custom_event_generator(
		"CharacterCreated", 
		function(context) return context:character():faction():name() == local_faction end, 
		"ScriptEventPlayerFactionCharacterCreated", 
		function(context) return context:character() end
	);
	
	core:start_custom_event_generator(
		"BuildingCompleted", 
		function(context) return context:garrison_residence():faction():name() == local_faction end, 
		"ScriptEventPlayerBuildingCompleted", 
		function(context) return context:building(), context:garrison_residence() end
	);
	
	core:start_custom_event_generator(
		"GarrisonOccupiedEvent", 
		function(context) return context:character():faction():name() == local_faction end, 
		"ScriptEventPlayerCaptureSettlement", 
		function(context) return context:garrison_residence(), context:character() end
	);
	
	core:start_custom_event_generator(
		"RegionGainedDevlopmentPoint", 
		function(context) return context:region():owning_faction():name() == local_faction end, 
		"ScriptEventPlayerRegionGainedDevelopmentPoint", 
		function(context) return context:region() end
	);
	
	core:start_custom_event_generator(
		"CharacterWaaaghOccurred", 
		function(context) 
			local char_faction_name = context:character():faction():name();
			if char_faction_name == local_faction or char_faction_name == local_faction .. "_waaagh" or char_faction_name == local_faction .. "_brayherd" then
				return true;
			end;
		end, 
		"ScriptEventPlayerCharacterWaaaghOccurred", 
		function(context) return context:character() end
	);
	
	core:start_custom_event_generator(
		"CharacterWaaaghOccurred", 
		function(context)
			local char_faction_name = context:character():faction():name();
			if not (char_faction_name == local_faction or char_faction_name == local_faction .. "_waaagh" or char_faction_name == local_faction .. "_brayherd") then
				return true;
			end;
		end, 
		"ScriptEventNonPlayerCharacterWaaaghOccurred", 
		function(context) return context:character() end
	);
		
	core:start_custom_event_generator(
		"CharacterSkillPointAvailable", 
		function(context) return context:character():faction():name() == local_faction end, 
		"ScriptEventPlayerCharacterSkillPointAvailable", 
		function(context) 
			return context:character();
		end
	);
	
	core:start_custom_event_generator(
		"CharacterFinishedMovingEvent", 
		function(context) return context:character():faction():name() == local_faction end, 
		"ScriptEventPlayerCharacterFinishedMovingEvent", 
		function(context) 
			return context:character();
		end
	);
	
	core:start_custom_event_generator(
		"PanelClosedCampaign", 
		function(context) 
			if context.string == "events" then
				-- test to see if the event_mission component is visible
				local uic = find_uicomponent(ui_root, "events", "event_mission");
				
				if uic and uic:Visible() then
					return true;
				end;
			end;
			return false
		end, 
		"ScriptEventPlayerAcceptsMission"
	);
	
	core:start_custom_event_generator(
		"RegionWindsOfMagicChanged",
		function(context) 
			local region = context:region();
			
			-- return true if the player owns the affected settlement			
			if region:owning_faction():name() == local_faction then
				out("===== RegionWindsOfMagicChanged event received and region " .. region:name() .. " is owned by " .. local_faction .. ", returning true");
				return true;
			end;
			
			-- also return true if the player has any forces in that region
			if cm:faction_has_armies_in_region(cm:get_faction(local_faction), region) then
				out("===== RegionWindsOfMagicChanged event received and " .. local_faction .. " has armies in region " .. region:name() .. ", returning true");
				return true;
			end;
			
			return false;
		end, 
		"ScriptEventPlayerRegionWindsOfMagicChanged"
	);	
	
	core:start_custom_event_generator(
		"PanelOpenedCampaign", 
		function(context) 
			if context.string == "character_panel" then
				
				local uic_settlement = find_uicomponent(ui_root, "hud_center", "button_group_settlement", "button_create_army");
				if uic_settlement and (uic_settlement:CurrentState() == "down" or uic_settlement:CurrentState() == "selected") then
					return true;
				end;
			
				-- horde army
				local uic_horde_army = find_uicomponent(ui_root, "hud_center", "button_group_army_settled", "button_create_army");
				if uic_horde_army and (uic_horde_army:CurrentState() == "down" or uic_horde_army:CurrentState() == "selected") then
					return true;
				end;
				
				return false;
			end;		
			
			return false;
		end, 
		"ScriptEventRecruitLordPanelOpened"
	);
	
	
	-- post missionsucceeded listener
	-- Fires an additional event a short while after a mission has succeeded, allowing client scripts to know when a 
	-- player mission's rewards have definitely* been received
	-- (*unsafe)
	core:add_listener(
		"post_player_missionsucceeded_listener",
		"MissionSucceeded",
		function(context)
			return context:faction():name() == local_faction;
		end,
		function(context)
			local mission_key = context:mission():mission_record_key();
		
			cm:callback(
				function()
					core:trigger_event("ScriptEventPlayerMissionSucceeded", mission_key);
				end,
				0.2
			);
		end,
		false
	);
	
	
	core:start_custom_event_generator(
		"PanelOpenedCampaign", 
		function(context) 
			if context.string == "character_panel" then
				
				local uic_settlement = find_uicomponent(ui_root, "hud_center", "button_group_settlement", "button_create_army");
				if uic_settlement and (uic_settlement:CurrentState() == "down" or uic_settlement:CurrentState() == "selected") then
					return true;
				end;
			
				-- horde army
				local uic_horde_army = find_uicomponent(ui_root, "hud_center", "button_group_army_settled", "button_create_army");
				if uic_horde_army and (uic_horde_army:CurrentState() == "down" or uic_horde_army:CurrentState() == "selected") then
					return true;
				end;
				
				return false;
			end;		
			
			return false;
		end, 
		"ScriptEventRecruitLordPanelOpened"
	);
	
	
	
	-- campaign interaction monitors
	-- these listen for the player interacting with the UI and store a flag of whether that interaction has occurred which other scripts can query
	
	-- has player closed unit exchange panel
	uim:add_campaign_panel_closed_interaction_monitor("unit_exchange_panel_closed", "unit_exchange");
	
	-- has player closed diplomacy panel
	uim:add_campaign_panel_closed_interaction_monitor("diplomacy_panel_closed", "dropdown_diplomacy");
	
	-- has player researched a technology
	uim:add_interaction_monitor("technology_researched", "ResearchStarted", function(context) return context:faction():name() == local_faction end);
	
	-- has player recruited a unit
	uim:add_interaction_monitor("unit_recruited", "RecruitmentItemIssuedByPlayer", function() return true end);
	
	-- has player constructed a building
	uim:add_interaction_monitor("building_constructed", "BuildingConstructionIssuedByPlayer", function() return true end);
	
	-- has player assigned a character to office
	uim:add_interaction_monitor("office_assigned", "CharacterAssignedToPost", function(context) return context:character():faction():name() == local_faction end);
	
	-- has player raised a force
	uim:add_interaction_monitor("force_raised", "ScriptEventRaiseForceButtonClicked");	
	
	-- has player autoresolved
	uim:add_interaction_monitor(
		"autoresolve_selected", 
		"ComponentLClickUp", 
		function(context) 
			local uic = UIComponent(context.component);
			return uic:Id() == "button_autoresolve" and uicomponent_descended_from(uic, "popup_pre_battle");
		end
	);
	
	-- bretonnian vows button clicked
	core:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) 
			return UIComponent(context.component) == find_uicomponent(ui_root, "character_details_panel", "TabGroup", "vows");
		end, 
		"ScriptEventBretonnianVowsButtonClicked"
	);
	
	-- forbidden workshop button clicked
	core:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) 
			return UIComponent(context.component) == find_uicomponent(ui_root, "faction_buttons_docker", "button_group_management", "button_ikit_workshop");
		end, 
		"ScriptEventForbiddenWorkshopButtonClicked"
	);
	
	-- forbidden worskhop panel opened
	
	core:start_custom_event_generator(
		"PanelOpenedCampaign", 
		function(context) 
			return context.string == "ikit_workshop_panel";
		end, 
		"ScriptEventIkitWorkshopPanelOpened"
	);
	
	-- elector count button clicked
	core:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) 
			return UIComponent(context.component) == find_uicomponent(ui_root, "faction_buttons_docker", "button_group_management", "button_elector_counts");
		end, 
		"ScriptEventElectorCountButtonClicked"
	);

	-- wulfharts hunter button clicked
	core:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) 
			return UIComponent(context.component) == find_uicomponent(ui_root, "faction_buttons_docker", "button_group_management", "button_hunters");
		end, 
		"ScriptEventWulfhartsHuntersButtonClicked"
	);

	-- nakai temple button clicked
	core:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) 
			return UIComponent(context.component) == find_uicomponent(ui_root, "topbar_list_parent", "nakai_temples", "button_nakai_temples");
		end, 
		"ScriptEventDotGPButtonClicked"
	);

	-- shadowy dealings panel opened
	core:start_custom_event_generator(
		"PanelOpenedCampaign", 
		function(context) 
			return context.string == "shadowy_dealings_panel";
		end, 
		"ScriptEventShadowyDealingsPanelOpened"
	);

	-- clan contracts button clicked
	core:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) 
			return UIComponent(context.component) == find_uicomponent(ui_root, "shadowy_dealings_panel", "middle_section", "clan_contracts_button");
		end, 
		"ScriptEventClanButtonClicked"
	);

	-- athel tamarha panel opened
	core:start_custom_event_generator(
		"PanelOpenedCampaign", 
		function(context) 
			return context.string == "athel_tamarha_dungeon";
		end, 
		"ScriptEventAthelTamarhaPanelOpened"
	);

	-- groms cauldron panel opened
	core:start_custom_event_generator(
		"PanelOpenedCampaign", 
		function(context) 
			return context.string == "groms_cauldron";
		end, 
		"ScriptEventGromsCauldronPanelOpened"
	);

	-- worldrootss button clicked
	core:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) 
			return UIComponent(context.component) == find_uicomponent(ui_root, "faction_buttons_docker", "button_group_management", "button_world_roots");
		end, 
		"ScriptEventWorldrootsButtonClicked"
	);

	-- technology panel opened	
	core:start_custom_event_generator(
		"PanelOpenedCampaign", 
		function(context) 
			return context.string == "button_technology";
		end, 
		"ScriptEventTechnologyPanelOpened"
	);

	-- dwarf forge panel opened	
	core:start_custom_event_generator(
		"PanelOpenedCampaign", 
		function(context) 
			return context.string == "button_mortuary_cult";
		end, 
		"ScriptEventDwarfForgePanelOpened"
	);

	-- monitor for player stances
	core:add_listener(
		"player_stance_monitor",
		"ForceAdoptsStance",
		true,
		function(context)
			local mf = context:military_force();
			local stance = tostring(context:stance_adopted());
			
			-- out("ForceAdoptsStance event triggered, stance is " .. tostring(stance) .. " [" .. mf:active_stance() .. "]");
			
			if mf:faction():name() == local_faction then				
				if stance == "1" then
					-- march
					effect.set_advice_history_string_seen("march_stance");
					effect.set_advice_history_string_seen("has_adopted_stance");
				elseif stance == "2" then
					-- ambush
					effect.set_advice_history_string_seen("ambush_stance");
					effect.set_advice_history_string_seen("has_adopted_stance");
				elseif stance == "3" then
					-- raiding
					effect.set_advice_history_string_seen("raiding_stance");
					effect.set_advice_history_string_seen("has_adopted_stance");
				elseif stance == "5" then
					-- mustering
					effect.set_advice_history_string_seen("mustering_stance");
					-- effect.set_advice_history_string_seen("has_adopted_stance");	 -- doesn't count
				elseif stance == "11" then
					-- channelling
					effect.set_advice_history_string_seen("channelling_stance");
					effect.set_advice_history_string_seen("has_adopted_stance");
				elseif stance == "12" then
					-- underway // beast-paths
					effect.set_advice_history_string_seen("use_underway_stance");
					effect.set_advice_history_string_seen("has_adopted_stance");
				elseif stance == "14" then
					-- raidin' camp
					effect.set_advice_history_string_seen("raidin_camp_stance");
					effect.set_advice_history_string_seen("has_adopted_stance");
				end;
			
			else
				-- fire an event if the force is raiding the player's territory
				if stance == "3" or stance == "14" then				
					if mf:has_general() then
						local char = mf:general_character();
						if char:has_region() then
							local owning_faction = char:region():owning_faction();
							if not owning_faction:is_null_interface() and owning_faction:name() == local_faction then
								core:trigger_event("ForceRaidingPlayerTerritory", mf);
							end;
						end;
					end;
				end;
			end;
		end,
		true
	);
	
	-- instruct the campaign manager to fire an event informing listeners what the player's lowest public order region is on turn start
	cm:find_lowest_public_order_region_on_turn_start(local_faction);
	
	-- get the campaign manager to send success/failure messages when hero actions are committed against the player faction
	cm:start_hero_action_listener(local_faction);
	
	-- get the campaign manager to send out a ScriptEventRegionRebels event after the FactionTurnEnd event (the RegionRebels event is sent before)
	cm:generate_region_rebels_event_for_faction(local_faction);

end;






















--
--	Region Corruption monitor
--	monitors vampiric/chaos region corruption and applies regional effect bundles accordingly
--

vampiric_corruption_string = "wh_main_religion_undeath";
chaos_corruption_string = "wh_main_religion_chaos";
skaven_corruption_string = "wh2_main_religion_skaven";
untainted_corruption_string = "wh_main_religion_untainted";

-- red text corruption effect bundles
local vampire_corruption_effect_bundle = {
	"wh_main_bundle_region_vampiric_corruption_low",
	"wh_main_bundle_region_vampiric_corruption_medium",
	"wh_main_bundle_region_vampiric_corruption_high"
};

local chaos_corruption_effect_bundle = {
	"wh_main_bundle_region_chaos_corruption_low",
	"wh_main_bundle_region_chaos_corruption_medium",
	"wh_main_bundle_region_chaos_corruption_high"
};

-- red text
local vampire_attrition_effect_bundle = "wh_main_bundle_region_vampiric_corruption_attrition_bad";
local chaos_attrition_effect_bundle = "wh_main_bundle_region_chaos_corruption_attrition";

function setup_region_corruption_monitor()	
	local human_factions = cm:get_human_factions();
	
	local green_vampire_effect_bundle_applied = false;
	local green_chaos_effect_bundle_applied = false;
	
	-- if any player is vampire counts or chaos, then use the appropriate green-text corruption effect bundles (as Vampire/Chaos corruption would be good for them)
	-- this is currently broken in MP if humans play as vampire/chaos - both would see green text for both effects.
	for i = 1, #human_factions do
		local current_faction = cm:get_faction(human_factions[i]);
		
		if current_faction then
			local faction_culture = current_faction:culture();
			local faction_name = current_faction:name();
		
			if not green_vampire_effect_bundle_applied and (faction_culture == "wh_main_vmp_vampire_counts" or faction_culture == "wh2_dlc11_cst_vampire_coast") then
				green_vampire_effect_bundle_applied = true;
				
				vampire_corruption_effect_bundle = {
					"wh_main_bundle_region_vampiric_corruption_low_good",
					"wh_main_bundle_region_vampiric_corruption_medium_good",
					"wh_main_bundle_region_vampiric_corruption_high_good"
				};
				
				vampire_attrition_effect_bundle = "wh_main_bundle_region_vampiric_corruption_attrition";
			end;
			
			if not green_chaos_effect_bundle_applied then
				if faction_culture == "wh_main_chs_chaos" then
					green_chaos_effect_bundle_applied = true;
					
					chaos_corruption_effect_bundle = {
						"wh_main_bundle_region_chaos_corruption_low_good",
						"wh_main_bundle_region_chaos_corruption_medium_good",
						"wh_main_bundle_region_chaos_corruption_high_good"
					};
				elseif faction_name == "wh2_main_def_cult_of_pleasure" then
					chaos_attrition_effect_bundle = "wh_main_bundle_region_chaos_corruption_attrition_good";
				end;
			end;
		end;
	end;
	
	-- iterate through all regions and apply any vampire/non-vampire territory attrition
	determine_attrition_all_regions();	
	
	-- recalculate attrition at the start of a human turn
	core:add_listener(
		"corruption_monitor",
		"ScriptEventHumanFactionTurnStart",
		true,
		function()
			determine_attrition_all_regions();
		end,
		true
	);
	
	core:add_listener(
		"occupation_monitor",
		"GarrisonOccupiedEvent",
		true,
		function(context)
			local region = context:garrison_residence():region();
			
			determine_attrition(region);
		end,
		true
	);
	
	core:add_listener(
		"raze_monitor",
		"CharacterRazedSettlement",
		true,
		function(context)
			local region = context:character():region();
			if not region:is_null_interface() then
				determine_attrition(region);
			end
		end,
		true
	);
end;


function determine_attrition_all_regions()
	local region_list = cm:model():world():region_manager():region_list();
	for i = 0, region_list:num_items() - 1 do
		local current_region = region_list:item_at(i);
		
		determine_attrition(current_region);
	end;
end;


function determine_attrition(region)
	local majority = region:majority_religion();
	
	if majority == vampiric_corruption_string then
		apply_attrition(region, vampiric_corruption_string);
	elseif majority == untainted_corruption_string or majority == skaven_corruption_string then
		apply_attrition(region, untainted_corruption_string);
	elseif majority == chaos_corruption_string then
		apply_attrition(region, chaos_corruption_string);
	end;
	
	check_corruption_effect_bundle(region);
end;

function apply_attrition(region, religion)
	local name = region:name();
	
	-- efficiency saving - access the game interface directly
	local game_interface = cm:get_game_interface();
	
	game_interface:remove_effect_bundle_from_region("wh_main_bundle_region_untainted_attrition", name);
	game_interface:remove_effect_bundle_from_region(vampire_attrition_effect_bundle, name);
	game_interface:remove_effect_bundle_from_region(chaos_attrition_effect_bundle, name);
	
	-- always apply Vampire territory attrition when the region is owned by an undead faction
	if region:owning_faction():state_religion() == vampiric_corruption_string or religion == vampiric_corruption_string then
		game_interface:apply_effect_bundle_to_region(vampire_attrition_effect_bundle, name, 0);
	-- otherwise apply the attrition based on the corruption within the region
	elseif religion == chaos_corruption_string then		
		game_interface:apply_effect_bundle_to_region(chaos_attrition_effect_bundle, name, 0);
	else
		game_interface:apply_effect_bundle_to_region("wh_main_bundle_region_untainted_attrition", name, 0);
	end;
end;

-- apply an effect bundle based on the percentage of Vampiric or Chaos corruption which buffs Undead/Chaos units
function check_corruption_effect_bundle(region)
	local vampiric_corruption = region:religion_proportion("wh_main_religion_undeath");
	local chaos_corruption = region:religion_proportion("wh_main_religion_chaos");
	
	local name = region:name();
		
	-- check the level of corruption, remove all effect bundles then apply a new one based on the level
	if vampiric_corruption >= 0.01 then
		apply_corruption_effect_bundle(vampiric_corruption, name, vampire_corruption_effect_bundle);
	else
		remove_corruption_effect_bundles(name, vampire_corruption_effect_bundle);
	end;
	
	if chaos_corruption >= 0.01 then
		apply_corruption_effect_bundle(chaos_corruption, name, chaos_corruption_effect_bundle);
	else
		remove_corruption_effect_bundles(name, chaos_corruption_effect_bundle);
	end;
end;

function remove_corruption_effect_bundles(region_name, effect_bundles)
	-- efficiency saving - access the game interface directly
	local game_interface = cm:get_game_interface();

	for i = 1, #effect_bundles do
		local current_effect_bundle = effect_bundles[i];
		
		game_interface:remove_effect_bundle_from_region(current_effect_bundle, region_name);
	end;
end;

function apply_corruption_effect_bundle(corruption, name, effect_bundles)	
	remove_corruption_effect_bundles(name, effect_bundles);
	
	-- efficiency saving - access the game interface directly
	local game_interface = cm:get_game_interface();
	
	if corruption < 0.3 then
		game_interface:apply_effect_bundle_to_region(effect_bundles[1], name, 0);
	elseif corruption > 0.3 and corruption < 0.6 then
		game_interface:apply_effect_bundle_to_region(effect_bundles[2], name, 0);
	else
		game_interface:apply_effect_bundle_to_region(effect_bundles[3], name, 0);
	end;
end;










--	Battle script override
--	Automatically loads a script in any battle launched from campaign. This activates advice in the battle.
function add_battle_script_override()
	cm:add_custom_battlefield(
		"generic",											-- string identifier
		0,													-- x co-ord
		0,													-- y co-ord
		5000,												-- radius around position
		false,												-- will campaign be dumped
		"",													-- loading override
		"script/battle/campaign_battle/battle_start.lua",	-- script override
		"",													-- entire battle override
		0,													-- human alliance when battle override
		false,												-- launch battle immediately
		true,												-- is land battle (only for launch battle immediately)
		false												-- force application of autoresolver result
	);
end;


function remove_battle_script_override()
	cm:remove_custom_battlefield("generic");
end;













-- apply Chaos corruption via an effect bundle to a region that is razed by an army belonging to Chaos
function setup_chaos_raze_region_monitor()
	core:add_listener(
		"chaos_raze_region_monitor",
		"CharacterRazedSettlement",
		function(context) return context:character():faction():subculture() == "wh_main_sc_chs_chaos" end,
		function(context)
			local char = context:character();			
			if char:has_region() then
				local region = char:region():name();				
				cm:apply_effect_bundle_to_region("wh_main_bundle_region_chaos_corruption", region, 5);
			else
				script_error("ERROR: chaos_raze_region_monitor listener triggered but character does not have a valid region - how can this be?");
			end;
		end,
		true
	);
end;














-- restrict confederation for duration of penalty
function start_confederation_listeners()
	core:add_listener(
		"confederation_listener",
		"FactionJoinsConfederation",
		true,
		function(context)
			local faction = context:confederation();
			local faction_name = faction:name();
			local faction_culture = faction:culture();
			local faction_subculture = faction:subculture();
			local faction_human = faction:is_human();
			local confederation_timeout = 5;
			
			-- exclude Empire, Wood Elves, Beastmen, Norsca, Greenskins and Bretonnia - they can confederate as often as they like but only if they aren't AI
			if faction_human == false or (faction_subculture ~= "wh_main_sc_emp_empire" and faction_culture ~= "wh_dlc03_bst_beastmen" and faction_culture ~= "wh_dlc05_wef_wood_elves" and (faction_culture ~= "wh_main_brt_bretonnia" or faction_name == "wh2_dlc14_brt_chevaliers_de_lyonesse") and faction_subculture ~= "wh_main_sc_nor_norsca" and faction_subculture ~= "wh_main_sc_grn_greenskins") then
				if faction_human == false then
					confederation_timeout = 10;
				end

				out("Restricting confederation between [faction:" .. faction_name .. "] and [subculture:" .. faction_subculture .. "]");
				cm:force_diplomacy("faction:" .. faction_name, "subculture:" .. faction_subculture, "form confederation", false, true, false);
				cm:add_turn_countdown_event(faction_name, confederation_timeout, "ScriptEventConfederationExpired", faction_name);
			end
			
			local source_faction = context:faction();
			local source_faction_name = source_faction:name();
			
			-- remove deathhag after confederating/being confedrated with cult of pleasure
			if source_faction:culture() == "wh2_main_def_dark_elves" and faction_name == "wh2_main_def_cult_of_pleasure" then
				local char_list = faction:character_list();
				
				for i = 0, char_list:num_items() - 1 do
					local current_char = char_list:item_at(i);
					
					if current_char:has_skill("wh2_main_skill_all_dummy_agent_actions_def_death_hag") then
						cm:kill_character(current_char:command_queue_index(), true, true);
					end
				end
			elseif faction_culture == "wh2_main_def_dark_elves" and source_faction_name == "wh2_main_def_cult_of_pleasure" then
				local char_list = faction:character_list();
				
				for i = 0, char_list:num_items() - 1 do
					local current_char = char_list:item_at(i);
					
					if current_char:has_skill("wh2_main_skill_all_dummy_agent_actions_def_death_hag_chs") then
						cm:kill_character(current_char:command_queue_index(), true, true);
					end
				end
			elseif faction_name == "wh2_dlc13_lzd_spirits_of_the_jungle" then
				local defender_faction = cm:model():world():faction_by_key("wh2_dlc13_lzd_defenders_of_the_great_plan");
				
				cm:disable_event_feed_events(true, "", "wh_event_subcategory_diplomacy_treaty_broken", "");
				cm:disable_event_feed_events(true, "", "", "diplomacy_treaty_negotiated_vassal");

				if defender_faction:is_null_interface() == false then
					if defender_faction:is_dead() == true and faction:has_home_region() == true then
						local home_region = faction:home_region():name();

						local x, y = cm:find_valid_spawn_location_for_character_from_settlement(
							"wh2_dlc13_lzd_defenders_of_the_great_plan",
							home_region,
							false,
							true
						);

						cm:create_force(
							"wh2_dlc13_lzd_defenders_of_the_great_plan",
							"wh2_main_lzd_inf_skink_cohort_0",
							home_region,
							x, y,
							true,
							function(char_cqi, force_cqi)
								handover_nakai_region();
								cm:kill_character(char_cqi, true, true);
							end
						);
					else
						handover_nakai_region();
					end
					
					if defender_faction:is_vassal() == false then
						cm:force_make_vassal("wh2_dlc13_lzd_spirits_of_the_jungle", "wh2_dlc13_lzd_defenders_of_the_great_plan");
						cm:force_diplomacy("faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "all", "all", false, false, false);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_spirits_of_the_jungle", "faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "war", false, false, true);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_spirits_of_the_jungle", "faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "break vassal", false, false, true);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "all", "war", false, true, false);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "all", "peace", false, true, false);
					end
				end
	
				cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_diplomacy_treaty_broken", "") end, 1);
				cm:callback(function() cm:disable_event_feed_events(false, "", "","diplomacy_treaty_negotiated_vassal") end, 1);
			elseif source_faction_name == "wh2_dlc13_lzd_spirits_of_the_jungle" then
				cm:disable_event_feed_events(true, "", "wh_event_subcategory_diplomacy_treaty_broken", "");
				cm:disable_event_feed_events(true, "", "", "diplomacy_treaty_negotiated_vassal");

				cm:force_confederation(faction_name, "wh2_dlc13_lzd_defenders_of_the_great_plan");

				cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_diplomacy_treaty_broken", "") end, 1);
				cm:callback(function() cm:disable_event_feed_events(false, "", "", "diplomacy_treaty_negotiated_vassal") end, 1);
			end
		end,
		true
	);
	
	core:add_listener(
		"confederation_expired",
		"ScriptEventConfederationExpired",
		true,
		function(context)
			local faction_name = context.string;
			local faction = cm:get_faction(faction_name);
			local subculture = faction:subculture();
			
			out("Unrestricting confederation between [faction:" .. faction_name .. "] and [subculture: " .. subculture .. "]");
			cm:force_diplomacy("faction:" .. faction_name, "subculture:" .. subculture, "form confederation", true, true, false);

			---hack fix to stop this re-enabling confederation when it needs to stay disabled
			---please let's make this more robust!
			if subculture == "wh2_main_sc_hef_high_elves" then
				local grom_faction = cm:get_faction("wh2_dlc15_grn_broken_axe")
				if grom_faction ~= false and grom_faction:is_human() then
					cm:force_diplomacy("subculture:wh2_main_sc_hef_high_elves","faction:wh2_main_hef_yvresse","form confederation", false, true, false);
				end
			end
		end,
		true
	);
end;







function handover_nakai_region()
	local nakai_faction = cm:model():world():faction_by_key("wh2_dlc13_lzd_spirits_of_the_jungle");
	local faction_regions = nakai_faction:region_list();
	
	for i = 0, faction_regions:num_items() - 1 do
		local region = faction_regions:item_at(i);
		local region_name = region:name();
		cm:transfer_region_to_faction(region_name, "wh2_dlc13_lzd_defenders_of_the_great_plan");
		create_region_temple(region);
	end
end







-- increase upkeep for each additional army the player recruits or obtains via confederation
function player_army_count_listener()
	-- apply the effect bundles every time the player turn starts
	core:add_listener(
		"player_army_turn_start_listener",
		"ScriptEventHumanFactionTurnStart",
		function(context)
			return upkeep_penalty_condition(context:faction());
		end,
		function(context)
			apply_upkeep_penalty(context:faction());
		end,
		true
	);

	-- apply the effect bundles every time the player creates a new force
	core:add_listener(
		"player_army_created_listener",
		"MilitaryForceCreated",
		function(context)
			return upkeep_penalty_condition(context:military_force_created():faction());
		end,
		function(context)
			apply_upkeep_penalty(context:military_force_created():faction());
		end,
		true
	);
	
	-- apply the effect bundles every time the player confederates
	core:add_listener(
		"confederation_player_army_count_listener",
		"FactionJoinsConfederation",
		function(context)
			return upkeep_penalty_condition(context:confederation());
		end,
		function(context)
			apply_upkeep_penalty(context:confederation());
		end,
		true
	);

	core:add_listener(
		"disband_player_army_count",
		"UnitDisbanded",
		function(context)
			local unit = context:unit();
			local has_unit_commander = unit:has_unit_commander();
			return has_unit_commander == true and upkeep_penalty_condition(unit:faction());
		end,
		function(context)
			local faction = context:unit():faction();

			cm:callback(function()
				apply_upkeep_penalty(faction);
			end, 0.5)
		end,
		true
	);
end

function upkeep_penalty_condition(faction)
	local culture = faction:culture();
	
	return faction:is_human() and not wh_faction_is_horde(faction) and culture ~= "wh_main_brt_bretonnia" and culture ~= "wh2_dlc09_tmb_tomb_kings";
end;

local leader_subtype_upkeep_exclusions = {
	["wh2_main_def_black_ark"] = true,
	["wh2_pro08_neu_gotrek"] = true,
	["wh2_main_def_black_ark_blessed_dread"] = true
};

-- loop through the player's armys and apply
function apply_upkeep_penalty(faction)
	local difficulty = cm:model():combined_difficulty_level();
	
	local effect_bundle = "wh_main_bundle_force_additional_army_upkeep_easy";				-- easy
	
	if(cm:is_multiplayer()) then
		-- In multiplayer we force everyone's upkeep difficulty to 2% (normal) to avoid desyncs
		effect_bundle = "wh_main_bundle_force_additional_army_upkeep_normal";
	else
		if difficulty == 0 then
			effect_bundle = "wh_main_bundle_force_additional_army_upkeep_normal";				-- normal
		elseif difficulty == -1 then
			effect_bundle = "wh_main_bundle_force_additional_army_upkeep_hard";					-- hard
		elseif difficulty == -2 then
			effect_bundle = "wh_main_bundle_force_additional_army_upkeep_very_hard";			-- very hard
		elseif difficulty == -3 then
			effect_bundle = "wh_main_bundle_force_additional_army_upkeep_legendary";			-- legendary
		end
	end
	
	local mf_list = faction:military_force_list();
	local army_list = {};
	
	for i = 0, mf_list:num_items() - 1 do
		local current_mf = mf_list:item_at(i);
		local force_type = current_mf:force_type():key()
		
		if current_mf:is_armed_citizenry() == false and current_mf:has_general() == true and force_type ~= "SUPPORT_ARMY"  then
			local general = current_mf:general_character();
			local character_subtype_key = general:character_subtype_key();
			local cqi = general:command_queue_index();

			if leader_subtype_upkeep_exclusions[character_subtype_key] == nil then
				table.insert(army_list, current_mf);
				cm:remove_effect_bundle_from_characters_force(effect_bundle, cqi);
			end
		end
	end
	
	if #army_list > 1 then
		for i = 1, #army_list - 1 do
			local current_mf = army_list[i];
			
			if not current_mf:has_effect_bundle(effect_bundle) then
				cm:apply_effect_bundle_to_characters_force(effect_bundle, army_list[i]:general_character():cqi(), 0, true);
			end
		end
	end
end













-- because rebels do not get siege equipment via the cultural trait system, we have to add them to the force manually
-- to only suitable way to determine which siege equipment to apply to which force is to perform a search on the unit key :(
function setup_rebel_army_siege_equipment_monitor()	
	cm:add_faction_turn_start_listener_by_name(
		"rebel_army_monitor",
		"rebels",
		function(context)
			local char_list = context:faction():character_list();
			for i = 0, char_list:num_items() - 1 do
				current_char = char_list:item_at(i);
				if current_char:has_military_force() then
					local cqi = current_char:military_force():command_queue_index();
					local unit = current_char:military_force():unit_list():item_at(0):unit_key();
					determine_siege_equipment_bundle(cqi, unit)
				end;
			end;
		end,
		true
	);
end;

function determine_siege_equipment_bundle(cqi, unit)
	if string.find(unit, "_emp_") then
		cm:apply_effect_bundle_to_force("wh_main_bundle_force_siege_equipment_emp", cqi, 0);
	elseif string.find(unit, "_dwf_") then
		cm:apply_effect_bundle_to_force("wh_main_bundle_force_siege_equipment_dwf", cqi, 0);
	elseif string.find(unit, "_brt_") then
		cm:apply_effect_bundle_to_force("wh_main_bundle_force_siege_equipment_brt", cqi, 0);
	elseif string.find(unit, "_grn_") then
		cm:apply_effect_bundle_to_force("wh_main_bundle_force_siege_equipment_grn", cqi, 0);
	elseif string.find(unit, "_vmp_") then
		cm:apply_effect_bundle_to_force("wh_main_bundle_force_siege_equipment_vmp", cqi, 0);
	elseif string.find(unit, "_chs_") then
		cm:apply_effect_bundle_to_force("wh_main_bundle_force_siege_equipment_chs", cqi, 0);
	elseif string.find(unit, "_bst_") then
		cm:apply_effect_bundle_to_force("wh_dlc03_bundle_force_siege_equipment_bst", cqi, 0);
	elseif string.find(unit, "_wef_") then
		cm:apply_effect_bundle_to_force("wh_dlc05_bundle_force_siege_equipment_wef", cqi, 0);
	elseif string.find(unit, "_nor_") then
		cm:apply_effect_bundle_to_force("wh_dlc08_bundle_force_siege_equipment_nor", cqi, 0);
	elseif string.find(unit, "_hef_") then
		cm:apply_effect_bundle_to_force("wh2_main_bundle_force_siege_equipment_hef", cqi, 0);
	elseif string.find(unit, "_def_") then
		cm:apply_effect_bundle_to_force("wh2_main_bundle_force_siege_equipment_def", cqi, 0);
	elseif string.find(unit, "_lzd_") then
		cm:apply_effect_bundle_to_force("wh2_main_bundle_force_siege_equipment_lzd", cqi, 0);
	elseif string.find(unit, "_skv_") then
		cm:apply_effect_bundle_to_force("wh2_main_bundle_force_siege_equipment_skv", cqi, 0);
	elseif string.find(unit, "_tmb_") then
		cm:apply_effect_bundle_to_force("wh2_dlc09_bundle_force_siege_equipment_tmb", cqi, 0);
	elseif string.find(unit, "_cst_") then
		cm:apply_effect_bundle_to_force("wh2_dlc11_bundle_force_siege_equipment_cst", cqi, 0);	
	else
		script_error("ERROR: determine_siege_equipment_bundle() called but cannot find a suitable effect bundle to apply to the rebel force!");
	end;
end;







function blood_pack_incidents_listener()
	core:add_listener(
		"carnage_event_listener",
		"IncidentOccuredEvent",
		function(context)
			local incident = context:dilemma();
			return incident == "wh_dlc02_incident_all_charge_carnage" or incident == "wh_dlc02_incident_all_magic_carnage" or incident == "wh_dlc02_incident_all_weapon_carnage";
		end,
		function(context) apply_effect_bundle_carnage(context:dilemma()) end,
		true
	);
end;

function apply_effect_bundle_carnage(incident)
	local incident = tostring(incident);
	local faction_list = cm:model():world():faction_list();
	local effect_to_apply = "wh_dlc02_payload_all_charge_carnage";

	if not cm:is_multiplayer() then
		if incident == "wh_dlc02_incident_all_magic_carnage" then
			effect_to_apply = "wh_dlc02_payload_all_magic_carnage";
		elseif incident == "wh_dlc02_incident_all_weapon_carnage" then
			effect_to_apply = "wh_dlc02_payload_all_weapon_carnage";
		end;

		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			
			local military_force_list = faction:military_force_list();
			
			for j = 0, military_force_list:num_items() - 1 do
				local mf = military_force_list:item_at(j);
				cm:apply_effect_bundle_to_force(effect_to_apply, mf:command_queue_index(), 10);
			end;
		end;
	end;
end;


-- for all human High Elf factions, reveal the shroud on regions belonging to factions that they are trading with
function elven_espionage_monitor()
	-- reveal the shroud on game start
	cm:disable_event_feed_events(true, "", "", "diplomacy_faction_encountered");
	
	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		local faction = cm:get_faction(human_factions[i]);
		
		if faction:culture() == "wh2_main_hef_high_elves" then
			elven_espionage_reveal_shroud(faction);
		end;
	end;
	
	cm:callback(function() cm:disable_event_feed_events(false, "", "", "diplomacy_faction_encountered") end, 1);
	
	-- reveal the shroud on the faction's turn start
	core:add_listener(
		"elven_espionage_turn_start",
		"ScriptEventHumanFactionTurnStart",
		function(context)
			return context:faction():culture() == "wh2_main_hef_high_elves";
		end,
		function(context)
			elven_espionage_reveal_shroud(context:faction());
		end,
		true
	);
	
	-- reveal the shroud when a trade deal is made, if it's the player's turn
	core:add_listener(
		"elven_espionage_trade_established",
		"TradeRouteEstablished",
		function(context)
			local faction = context:faction();
			
			return faction:is_human() and faction:culture() == "wh2_main_hef_high_elves" and faction == cm:model():world():whose_turn_is_it();
		end,
		function(context)
			elven_espionage_reveal_shroud(context:faction());
		end,
		true
	);
end;

function elven_espionage_reveal_shroud(faction)
	local effect_bundle = "wh2_main_bundle_faction_elven_espionage";
	
	local has_effect_bundle = faction:has_effect_bundle(effect_bundle);
	
	local factions_trading_with = faction:factions_trading_with();
	local faction_name = faction:name();
	
	if factions_trading_with:num_items() > 0 then
		if has_effect_bundle then
			cm:apply_effect_bundle(effect_bundle, faction_name, 0);
		end;
	
		for i = 0, factions_trading_with:num_items() - 1 do
			local current_faction = factions_trading_with:item_at(i);
			local current_faction_regions = current_faction:region_list();
			
			for j = 0, current_faction_regions:num_items() - 1 do
				local current_region_name = current_faction_regions:item_at(j):name();
				
				cm:make_region_visible_in_shroud(faction_name, current_region_name);
			end;
		end;
	elseif has_effect_bundle then
		cm:remove_effect_bundle(effect_bundle, faction_name);
	end;
end;
	
function show_how_to_play_event(faction_name, end_callback, delay)
	
	if not is_string(faction_name) then
		script_error("ERROR: show_how_to_play_event() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	if end_callback and not is_function(end_callback) then
		script_error("ERROR: show_how_to_play_event() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if delay and not is_number(delay) then
		script_error("ERROR: show_how_to_play_event() called but supplied end callback delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;

	local title = "event_feed_strings_text_wh2_scripted_event_how_they_play_title";
	local primary_detail = "factions_screen_name_" .. faction_name;
	local secondary_detail = "";
	local pic = nil;
	
	--[[
		Empire event messages handled in wh_main_emp_empire_start.lua
	]]
	
	if faction_name == "wh_main_grn_greenskins" then
		secondary_detail = "event_feed_strings_text_wh_main_event_feed_string_scripted_event_intro_greenskins_secondary_detail";
		pic = 593;
	elseif faction_name == "wh_main_vmp_vampire_counts" then
		secondary_detail = "event_feed_strings_text_wh_main_event_feed_string_scripted_event_intro_vampires_secondary_detail";
		pic = 594;
	elseif faction_name == "wh2_dlc11_vmp_the_barrow_legion" then
		secondary_detail = "event_feed_strings_text_wh_main_event_feed_string_scripted_event_intro_vampires_secondary_detail";
		pic = 594;	
	elseif faction_name == "wh_main_dwf_dwarfs" then
		secondary_detail = "event_feed_strings_text_wh_main_event_feed_string_scripted_event_intro_dwarfs_secondary_detail";
		pic = 592;
	elseif faction_name == "wh_main_dwf_karak_kadrin" then
		secondary_detail = "event_feed_strings_text_wh_main_event_feed_string_scripted_event_intro_dwarfs_secondary_detail";
		pic = 592;
	elseif faction_name == "wh_main_chs_chaos" then
		secondary_detail = "event_feed_strings_text_wh_main_event_feed_string_scripted_event_intro_warriors_of_chaos_secondary_detail";
		pic = 595;
	
	
	--
	-- WH1 DLC
	--
	elseif faction_name == "wh_main_grn_orcs_of_the_bloody_hand" then
		secondary_detail = "event_feed_strings_text_wh_dlc06_event_feed_string_scripted_event_intro_wurrzag_secondary_detail";
		pic = 593;
	elseif faction_name == "wh_main_dwf_karak_izor" then
		secondary_detail = "event_feed_strings_text_wh_dlc06_event_feed_string_scripted_event_intro_belegar_secondary_detail";
		pic = 602;
	elseif faction_name == "wh_main_grn_crooked_moon" then
		secondary_detail = "event_feed_strings_text_wh_dlc06_event_feed_string_scripted_event_intro_skarsnik_secondary_detail";
		pic = 603;
	elseif faction_name == "wh_dlc03_bst_beastmen" then
		secondary_detail = "event_feed_strings_text_wh_main_event_feed_string_scripted_event_intro_beastmen_secondary_detail";
		pic = 596;
	elseif faction_name == "wh2_dlc17_bst_malagor" then
		secondary_detail = "event_feed_strings_text_wh_main_event_feed_string_scripted_event_intro_beastmen_secondary_detail";
		pic = 596;
	elseif faction_name == "wh_dlc05_bst_morghur_herd" then
		secondary_detail = "event_feed_strings_text_wh_main_event_feed_string_scripted_event_intro_beastmen_secondary_detail";
		pic = 596;

	elseif faction_name == "wh2_dlc17_bst_taurox" then
		secondary_detail = "event_feed_strings_text_wh2_dlc17_event_feed_string_scripted_event_intro_beastmen_taurox_secondary_detail";
		pic = 596;
	------------------------
	-- DLC05 - Wood Elves
	------------------------ 	
	elseif faction_name == "wh_dlc05_wef_wood_elves" then
		secondary_detail = "event_feed_strings_text_wh_dlc05_event_feed_string_scripted_event_intro_orion_secondary_detail";
		pic = 605;
	elseif faction_name == "wh_dlc05_wef_argwylon" then
		secondary_detail = "event_feed_strings_text_wh_dlc05_event_feed_string_scripted_event_intro_argwylon_secondary_detail";
		pic = 605;
	elseif faction_name == "wh_dlc05_wef_mini_wood_elves" then
		secondary_detail = "event_feed_strings_text_wh_dlc05_event_feed_string_scripted_event_intro_orion_mini_secondary_detail";
		pic = 605;
	elseif faction_name == "wh_dlc05_wef_mini_argwylon" then
		secondary_detail = "event_feed_strings_text_wh_dlc05_event_feed_string_scripted_event_intro_argwylon_mini_secondary_detail";
		pic = 605;
	elseif faction_name == "wh2_dlc16_wef_sisters_of_twilight" then
		if cm:get_campaign_name() == "wh2_main_great_vortex" then
			-- vortex campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_sisters_of_twilight_secondary_detail";
			pic = 798;
		else
			-- mortal empires campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_sisters_of_twilight_secondary_detail_ME";
			pic = 798;
		end
		
	elseif faction_name == "wh2_dlc16_wef_drycha" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_drycha_secondary_detail";
		pic = 605;
	-----------------------
	-- DLC07 - Bretonnia
	-----------------------
	-- King Louen
	elseif faction_name == "wh_main_brt_bretonnia" then
		secondary_detail = "event_feed_strings_text_wh_dlc07_event_feed_string_scripted_event_intro_bretonnia_secondary_detail";
		pic = 751;
	-- Alberic 	
	elseif faction_name == "wh_main_brt_bordeleaux" then
		secondary_detail = "event_feed_strings_text_wh_dlc07_event_feed_string_scripted_event_intro_bretonnia_secondary_detail";
		pic = 752;
	-- Fay Enchantress	
	elseif faction_name == "wh_main_brt_carcassonne" then
		secondary_detail = "event_feed_strings_text_wh_dlc07_event_feed_string_scripted_event_intro_bretonnia_secondary_detail";
		pic = 753;
	-- Repanse
	elseif faction_name == "wh2_dlc14_brt_chevaliers_de_lyonesse" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_chevaliers_de_lyonesse_secondary_detail";
		pic = 753;	
	-----------------------
	-- DLC08 - Norsca
	-----------------------
	-- Wulfrik the Wanderer
	elseif faction_name == "wh_dlc08_nor_norsca" then
		secondary_detail = "event_feed_strings_text_wh_dlc08_event_feed_string_scripted_event_intro_norsca_secondary_detail";
		pic = 800;
	-- Throgg
	elseif faction_name == "wh_dlc08_nor_wintertooth" then
		secondary_detail = "event_feed_strings_text_wh_dlc08_event_feed_string_scripted_event_intro_norsca_secondary_detail";
		pic = 800;	
	------------------------
	-- PRO2 - Isabella
	------------------------
	elseif faction_name == "wh_main_vmp_schwartzhafen" then
		secondary_detail = "event_feed_strings_text_wh_pro02_event_feed_string_scripted_event_intro_isabella_secondary_detail";
		pic = 770;
		
	------------------------
	-- WH2
	------------------------
	
	------------------------
	-- Dwarfs
	------------------------
	elseif faction_name == "wh2_dlc17_dwf_thorek_ironbrow" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_thorek_ironbrow_secondary_detail";
		pic = 1701;

	------------------------
	-- Empire
	------------------------
	
	-- Markus Wulfhart
	elseif faction_name == "wh2_dlc13_emp_the_huntmarshals_expedition" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_huntsmarshals_expedition_secondary_detail";
		pic = 591;
		
	------------------------
	-- Greenskins
	------------------------
	
	-- Grom
	elseif faction_name == "wh2_dlc15_grn_broken_axe" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_broken_axe_secondary_detail";
		pic = 797;	
		
	-- Azhag
	elseif faction_name == "wh2_dlc15_grn_bonerattlaz" then
		secondary_detail = "event_feed_strings_text_wh_main_event_feed_string_scripted_event_intro_greenskins_secondary_detail";
		pic = 593;	
	
	------------------------
	-- High Elves
	------------------------	
	
	-- Tyrion
	elseif faction_name == "wh2_main_hef_eataine" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_eataine_secondary_detail";
		pic = 771;
		
	-- Teclis
	elseif faction_name == "wh2_main_hef_order_of_loremasters" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_order_of_loremasters_secondary_detail";
		pic = 772;
		
	-- Alarielle the Radiant
	elseif faction_name == "wh2_main_hef_avelorn" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_avelorn_secondary_detail";
		pic = 780;
		
	-- Alith Anar
	elseif faction_name == "wh2_main_hef_nagarythe" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_nagarythe_secondary_detail";
		pic = 781;	
		
	-- Eltharion
	elseif faction_name == "wh2_main_hef_yvresse" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_yvresse_secondary_detail";
		pic = 795;	

	-- Imrik
	elseif faction_name == "wh2_dlc15_hef_imrik" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_caledor_secondary_detail";
		pic = 796;		

	------------------------
	-- Dark Elves
	------------------------
	
	-- Malekith
	elseif faction_name == "wh2_main_def_naggarond" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_naggarond_secondary_detail";
		pic = 773;
		
	-- Morathi
	elseif faction_name == "wh2_main_def_cult_of_pleasure" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_cult_of_pleasure_secondary_detail";
		pic = 774;
		
	-- Crone Hellebron
	elseif faction_name == "wh2_main_def_har_ganeth" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_har_ganeth_secondary_detail";
		pic = 779;	
		
	-- Lokhir Fellheart
	elseif faction_name == "wh2_dlc11_def_the_blessed_dread" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_the_blessed_dread_secondary_detail";
		pic = 782;	
		
	-- Malus Darkblade
	elseif faction_name == "wh2_main_def_hag_graef" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_hag_graef_secondary_detail";
		pic = 782;		
	
	-- Rakarth
	elseif faction_name == "wh2_twa03_def_rakarth" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_rakarth_secondary_detail";
		pic = 782;	

	------------------------
	-- Lizardmen
	------------------------
	
	-- Lord Mazdamundi
	elseif faction_name == "wh2_main_lzd_hexoatl" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_hexoatl_secondary_detail";
		pic = 775;
	
	-- Kroq-Gar
	elseif faction_name == "wh2_main_lzd_last_defenders" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_last_defenders_secondary_detail";
		pic = 776;
		
	-- Tehenhuain
	elseif faction_name == "wh2_dlc12_lzd_cult_of_sotek" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_cult_of_sotek_secondary_detail";
		pic = 788;

	-- Tiktaq'to
	elseif faction_name == "wh2_main_lzd_tlaqua" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_tlaqua_secondary_detail";
		pic = 776;	
		
	-- Nakai
	elseif faction_name == "wh2_dlc13_lzd_spirits_of_the_jungle" then
		if cm:get_campaign_name() == "wh2_main_great_vortex" then
			-- vortex campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_spirits_of_the_jungle_secondary_detail";
			pic = 776;	
		else
			-- mortal empires campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_spirits_of_the_jungle_secondary_detail_ME";
			pic = 776;
		end

	-- Gor-Rok
	elseif faction_name == "wh2_main_lzd_itza" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_itza_secondary_detail";
		pic = 776;			
	
	-- Oxyotl
	elseif faction_name == "wh2_dlc17_lzd_oxyotl" then
		if cm:get_campaign_name() == "wh2_main_great_vortex" then
			-- vortex campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_oxyotl_secondary_detail";
			pic = 801;
		else	
			-- mortal empires campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_oxyotl_secondary_detail_me";
			pic = 801;
		end	
	------------------------
	-- Skaven
	------------------------		
	
	-- Queek Headtaker
	elseif faction_name == "wh2_main_skv_clan_mors" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_clan_mors_secondary_detail";
		pic = 777;
	
	-- Lord Skrolk
	elseif faction_name == "wh2_main_skv_clan_pestilens" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_clan_pestilens_secondary_detail";
		pic = 778;
	
	-- Tretch Craventail
	elseif faction_name == "wh2_dlc09_skv_clan_rictus" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_clan_rictus_secondary_detail";
		pic = 778;
	
	-- Ikit Claw
	elseif faction_name == "wh2_main_skv_clan_skyre" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_clan_skyre_secondary_detail";
		pic = 787;	
		
	-- Death Master Snikch
	elseif faction_name == "wh2_main_skv_clan_eshin" then
		secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_clan_eshin_secondary_detail";
		pic = 787;		
		
	-- Throt the Unclean
	elseif faction_name == "wh2_main_skv_clan_moulder" then
		if cm:get_campaign_name() == "wh2_main_great_vortex" then
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_clan_moulder_secondary_detail_vortex";
			pic = 799;	
		else
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_clan_moulder_secondary_detail";
			pic = 799;	
		end
	-----------------------
	-- Tomb Kings
	-----------------------
	
	elseif cm:get_faction(faction_name):culture() == "wh2_dlc09_tmb_tomb_kings" then
		if cm:get_campaign_name() == "wh2_main_great_vortex" then
			-- vortex campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_tomb_kings_secondary_detail";
			pic = 606;
		else
			-- mortal empires campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_tomb_kings_secondary_detail_ME";
			pic = 606;
		end	
		
	-----------------------
	--Vampire Coast
	-----------------------
	
	elseif faction_name == "wh2_dlc11_cst_vampire_coast" then
		if cm:get_campaign_name() == "wh2_main_great_vortex" then
			-- vortex campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_vampire_coast_secondary_detail";
			pic = 786;
		else
			-- mortal empires campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_vampire_coast_secondary_detail_ME";
			pic = 786;
		end

	
	--Count Noctilus
	elseif faction_name == "wh2_dlc11_cst_noctilus" then
		if cm:get_campaign_name() == "wh2_main_great_vortex" then
			-- vortex campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_vampire_coast_secondary_detail";
			pic = 785;
		else
			-- mortal empires campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_vampire_coast_secondary_detail_ME";
			pic = 785;
		end
	
	--Aranessa Saltspite
	elseif faction_name == "wh2_dlc11_cst_pirates_of_sartosa" then
		if cm:get_campaign_name() == "wh2_main_great_vortex" then
			-- vortex campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_vampire_coast_secondary_detail";
			pic = 783;
		else
			-- mortal empires campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_vampire_coast_secondary_detail_ME";
			pic = 783;
		end
	
	--Cylostra Direfin
	elseif faction_name == "wh2_dlc11_cst_the_drowned" then
		if cm:get_campaign_name() == "wh2_main_great_vortex" then
			-- vortex campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_vampire_coast_secondary_detail";
			pic = 784;
		else
			-- mortal empires campaign
			secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_vampire_coast_secondary_detail_ME";
			pic = 784;
		end
	
	else
		script_error("ERROR: show_how_to_play_event() called but couldn't recognise supplied faction name [" .. faction_name .. "]");
		
		if end_callback then end_callback() end;
		
		return false;
	end
	
	cm:show_message_event(
		faction_name,
		title,
		primary_detail,
		secondary_detail,
		true,
		pic,
		end_callback,
		delay
	);
end;


local rank_up_character_turn_start_lookup = {};

function add_rank_up_character_turn_start_listener(character_subtype, rank_requirement)

	-- create a subtable corresponding to this character_subtype if it doesn't already exist, and then add an entry for this rank requirement
	if not is_table(rank_up_character_turn_start_lookup[character_subtype]) then
		rank_up_character_turn_start_lookup[character_subtype] = {};
		table.insert(rank_up_character_turn_start_lookup[character_subtype], rank_requirement);
	else
		table.insert(rank_up_character_turn_start_lookup[character_subtype], rank_requirement);
		table.sort(rank_up_character_turn_start_lookup[character_subtype]);		-- sort the table so that it's always in ascending order of rank
	end;

	core:call_once(
		"rank_up_character_turn_start_listener",
		function()
			core:add_listener(
				"rank_up_character_turn_start_listener",
				"CharacterTurnStart",
				true,
				function(context)
					local character_subtype_key = context:character():character_subtype_key();

					if rank_up_character_turn_start_lookup[character_subtype_key] and #rank_up_character_turn_start_lookup[character_subtype_key] > 0 then
						-- a character subtype table exists for this character subtype
						if rank_up_character_turn_start_lookup[character_subtype_key][1] <= context:character():rank() then
							-- the lowest rank in the table is less than the rank the character just achieved - trigger a script event which the quest listeners will respond to
							table.remove(rank_up_character_turn_start_lookup[character_subtype_key], 1);
							core:trigger_event("ScriptEventQuestCharacterTurnStart", context:character());
						end;
					end;
				end,
				true
			);
		end
	);
end;


-- trigger quests (data is set up in the respective campaign folder)
function set_up_rank_up_listener(quests, subtype, infotext, duefaction)	
	for i = 1, #quests do
		-- grab some local data for this quest record
		local current_quest_record = quests[i];
		
		local current_type = current_quest_record[1];
		local current_ancillary_key = current_quest_record[2];
		local current_mission_key = current_quest_record[3];
		local current_rank_req = current_quest_record[4];
		local current_mp_mission_key = current_quest_record[5];
		local current_advice_key = current_quest_record[6];
		local current_x = current_quest_record[7];
		local current_y = current_quest_record[8];
		local current_region_key = current_quest_record[9];
		local current_intervention_name = false;
		local current_saved_name = false;
		
		if current_mission_key then
			current_intervention_name = "in_" .. current_mission_key;
			current_saved_name = current_mission_key .. "_issued";
		else
			-- ai only, we don't have a mission for the player
			current_saved_name = current_ancillary_key .. "_issued";
		end;
		
		out.design("[Quests] establishing rank up listener for char type [" .. subtype .. "] and rank [" .. current_rank_req .. "] for mission [" .. tostring(current_mission_key) .. "]");
		out.design("\tadvice key is " .. tostring(current_advice_key) .. ", x is " .. tostring(current_x) .. " and y is " .. tostring(current_y));
		
		-- pre-declare the intervention and trigger function, so that they exist in this scope as a local
		local current_intervention = false;
		local current_intervention_trigger = false;
		
		-- only establish the intervention properly in single-player mode, however
		if not cm:is_multiplayer() and current_intervention_name then
			out.design("\testablishing intervention as it's a singleplayer campaign");
			
			--------------------------------------------
			-- called when the intervention is triggered
			function current_intervention_trigger()
				if current_intervention.char_cqi then 
					local chara = cm:get_character_by_cqi(current_intervention.char_cqi);
					if chara and not chara:faction():is_null_interface() and chara:faction():name() ~= duefaction and current_mp_mission_key then
						current_mission_key = current_mp_mission_key;
						current_type = "mission";
					end
				end
				out.design("[Quests] intervention triggering for [" .. current_mission_key .. "], character subtype [" .. subtype .. "]");
				
				-- save this value in order to not issue this quest multiple times
				cm:set_saved_value(current_saved_name, true);
				
				-- stop listener
				core:remove_listener(current_mission_key);
				
				-- set up a mission manager to trigger
				local mm = mission_manager:new(cm:get_local_faction_name(), current_mission_key);
				if current_type == "dilemma" then
					mm:set_is_dilemma_in_db(true);				-- first arg is true as this is triggered from within an intervention
					out.design("\tthis quest is a dilemma");
				elseif current_type == "incident" then
					mm:set_is_incident_in_db();
					out.design("\tthis quest is an incident");
				else
					mm:set_is_mission_in_db();
					out.design("\tthis quest is a mission");
				end;
				
				if core:is_advice_level_minimal() then
					out.design("\tjust issuing mission, advice level is minimal");
				
					-- advice is set to minimal, just trigger the mission
					mm:trigger(function() current_intervention:complete() end);	
					return;
				end;
				
				-- decide whether to show infotext or not
				local infotext_to_show = false
				if not effect.get_advice_history_string_seen("quests_infotext") then
					infotext_to_show = infotext;
					effect.set_advice_history_string_seen("quests_infotext");
				end;
				
				if current_advice_key and current_x and current_y then
					out.design("\tscrolling the camera with advice");
					
					-- we have advice to deliver and a position
					current_intervention:scroll_camera_for_intervention(
						current_region_key,
						current_x,
						current_y,
						current_advice_key,
						infotext_to_show,
						mm,
						4
					);
				elseif current_advice_key then
					-- we have advice, but no position
					out.design("\tplaying advice with no camera movement");
					
					current_intervention:play_advice_for_intervention(
						current_advice_key,
						infotext_to_show,
						mm
					);
				elseif current_x and current_y then
					-- we have a position but no advice
					out.design("\tscrolling camera with no advice");
					
					local cam_x, cam_y, cam_d, cam_b, cam_h = cm:get_camera_position();
					
					local cutscene = campaign_cutscene:new(
						current_mission_key,
						4,
						function()
							-- trigger mission when cutscene finishes
							mm:trigger(
								function()
									-- restore shroud and complete when mission is accepted
									cm:restore_shroud_from_snapshot();
									current_intervention:complete() 
								end
							);
						end
					);
					
					cutscene:set_skippable(true);
					cutscene:set_skip_camera(current_x, current_y, cam_d, cam_b, cam_h);
					cutscene:set_disable_settlement_labels(false);
					cutscene:set_dismiss_advice_on_end(false);
					cutscene:set_restore_shroud(false);
					
					-- make the target region visible if we have one
					if current_region_key then
						cutscene:action(function() cm:make_region_visible_in_shroud(cm:get_local_faction_name(), current_region_key) end, 0);
					end;
					cutscene:action(function() cm:scroll_camera_from_current(true, 4, {current_x, current_y, cam_d, cam_b, cam_h}) end, 0);
					
					cutscene:start();
				else
					-- we have no position or advice, just trigger
					out.design("\tno advice or position to scroll to, just issuing mission");
					
					mm:trigger(function() current_intervention:complete() end);
					
					-- failsafe check - if we're still running three seconds after triggering the mission/incident/dilemma, and no event panel is on-screen,
					-- then complete anyway and complain about it on the console
					cm:callback(
						function() 
							if current_intervention.is_active and not cm:get_campaign_ui_manager():is_event_panel_open() then
								local type_for_display = "mission";
								
								if current_type == "dilemma" then
									type_for_display = "dilemma";
								elseif current_type == "incident" then
									type_for_display = "incident";
								end;
								
								script_error("ERROR - attempted to trigger " .. type_for_display .. " [" .. current_mission_key .. "] as part of quest chain but no event message seems to have been generated. Proceeding anyway, but the quest chain will be broken. This is a serious error, please notify designers.");
								
								-- cancel the dismiss listener registered with the mission manager
								mm:cancel_dismiss_callback_listeners();
									
								current_intervention:complete();
							end;
						end, 
						3
					);
				end;
			end;
			--------------------------------------------
			--------------------------------------------
			
			-- declare the intervention itself
			current_intervention = intervention:new(
				current_intervention_name,							-- string name
				0,	 												-- cost
				function() current_intervention_trigger() end,		-- trigger callback
				BOOL_INTERVENTIONS_DEBUG	 						-- show debug output
			);

			current_intervention:set_disregard_cost_when_triggering(true);
		end;
		
		-- establish listeners for this character rank-up event if the quest chain has not already been started
		if cm:get_saved_value(current_saved_name) then
			out.design("\tthis quest has already been triggered, not establishing listeners");
		else
			out.design("\tthis quest has not been triggered, establishing listeners");

			-- Register listener for this character ranking up
			-- We now only have one CharacterTurnStart listener, which communicates using the ScriptEventQuestCharacterTurnStart event when a quest battle character has actually ranked up in a way we're interested in
			add_rank_up_character_turn_start_listener(subtype, current_rank_req);
			
			-- start ScriptEventQuestCharacterTurnStart listener
			core:add_listener(
				current_ancillary_key,
				"ScriptEventQuestCharacterTurnStart",
				function(context)
					return context:character():character_subtype(subtype) and context:character():rank() >= current_rank_req 
				end,
				function(context)
					local character = context:character();
					out.design("[Quests] Character [" .. cm:char_lookup_str(character) .. "] of subtype [" .. subtype .. "] has achieved rank [" .. current_rank_req .. "]");
					
					-- if the character is player controlled then begin the quest chain
					if character:faction():is_human() then
						if cm:is_multiplayer() or cm:get_saved_value("advice_is_disabled") then
							-- save this value in order to not issue this quest multiple times
							cm:set_saved_value(current_saved_name, true);	-- don't do this if the intervention is going to be triggered
							
							-- character is player-controlled and this is a multiplayer game, trigger the mission/dilemma etc
							if current_type == "mission" then
								if current_mp_mission_key and (cm:is_multiplayer() or (duefaction and character:faction() ~= duefaction)) then
									current_mission_key = current_mp_mission_key;
									out.design("\tcharacter is player controlled and this is an mp game or advice is disabled, triggering mission " .. current_mission_key);
									cm:trigger_mission(character:faction():name(), current_mission_key, true);
								else
									out.design("\tcharacter is player controlled and this is an mp game or advice is disabled, triggering mission " .. current_mission_key);
									cm:trigger_mission(character:faction():name(), current_mission_key, true);
								end;
							elseif current_type == "dilemma" then
								if current_mp_mission_key and (cm:is_multiplayer() or (duefaction and character:faction() ~= duefaction)) then
									current_mission_key = current_mp_mission_key;
									out.design("\tcharacter is player controlled and this is an mp game or advice is disabled, triggering mission " .. current_mission_key);
									cm:trigger_mission(character:faction():name(), current_mission_key, true);
								else
									out.design("\tcharacter is player controlled and this is an mp game or advice is disabled, triggering dilemma " .. current_mission_key);
									cm:trigger_dilemma(character:faction():name(), current_mission_key);
								end;	
							elseif current_type == "incident" then
								if current_mp_mission_key and (cm:is_multiplayer() or (duefaction and character:faction() ~= duefaction)) then
									current_mission_key = current_mp_mission_key;
									out.design("\tcharacter is player controlled and this is an mp game or advice is disabled, triggering mission " .. current_mission_key);
									cm:trigger_mission(character:faction():name(), current_mission_key, true);
								else
									out.design("\tcharacter is player controlled and this is an mp game or advice is disabled, triggering incident " .. current_mission_key);
									cm:trigger_incident(character:faction():name(), current_mission_key, true);
								end;	
							elseif current_type == "ai_only" then
								-- don't do anything
							else
								out.design("\tcouldn't determine mission type [" .. tostring(current_type) .. "] - see script error");
								script_error("ERROR: Tried to start a quest, but the event type [" .. tostring(current_type) .. " could not be parsed!");
							end;
						elseif current_mission_key then
							-- character is player-controlled and this is a single-player game, sending a scriptevent that will trigger the intervention
							out.design("\tthis is a single-player campaign, triggering a message for the intervention");
							current_intervention.char_cqi = context:character():cqi();
							core:trigger_event("ScriptEventTriggerQuestChain", current_mission_key);
						end;
					else
						out.design("\tcharacter is not player-controlled, immediately giving them ancillary [" .. current_ancillary_key .. "]");
						
						-- save this value in order to not issue this quest multiple times
						cm:set_saved_value(current_saved_name, true);
						
						-- character is AI-controlled, give them the ancillary
						cm:force_add_ancillary(character, current_ancillary_key, false, false);
					end;
				end,
				false
			);
			
			-- if it's a single-player game, then set up the intervention monitors
			if not cm:is_multiplayer() and current_intervention then
				-- listen for the scriptevent message, triggered from the monitor above if the player levels up a char on their turn
				current_intervention:add_trigger_condition(
					"ScriptEventTriggerQuestChain",
					function(context)
						return context.string == current_mission_key;
					end
				);
				
				current_intervention:start();
			end;
		end;
	end;
end;



function set_up_backup_mission(origin_mission, backup_mission, subtype)
	core:add_listener(
		origin_mission .. "_backup",
		"MissionGenerationFailed",
		function(context) return context:mission() == origin_mission end,
		function()
			out("Could not issue quest chain mission key [" .. origin_mission .. "] to faction owning agent subtype [" .. subtype .. "] - going to issue mission key [ " .. backup_mission .. "]");
			
			-- get the character's faction name, it might have changed if they've been confederated
			local faction_name = nil;
			local faction_list = cm:model():world():faction_list();
			
			for i = 0, faction_list:num_items() - 1 do
				local current_faction = faction_list:item_at(i);
				local char_list = current_faction:character_list();
				
				for j = 0, char_list:num_items() - 1 do
					local current_char = char_list:item_at(j);
					
					if current_char:character_subtype(subtype) then
						faction_name = current_char:faction():name();
						break;
					end;
				end;
				
				if faction_name then
					break;
				end;
			end;
			
			if faction_name then
				cm:trigger_mission(faction_name, backup_mission, true);
			end;
		end,
		false
	);
end;

function add_intercontinental_diplomacy_listener()
	core:add_listener(
		"intercontinental_diplomacy_listener",
		"FactionTurnStart",
		function(context)
			return cm:model():turn_number() == intercontinental_diplomacy_turn;
		end,
		function(context)
			if not cm:get_saved_value("intercontinental_diplomacy_available") then
				make_intercontinental_diplomacy_available(true, 80000);
			end
		end,
		false
	);
end

-- makes diplomacy available between owners of major port settlements
function make_intercontinental_diplomacy_available(show_event, max_distance)
	if show_event then
		local human_factions = cm:get_human_factions();
		
		for i = 1, #human_factions do
			cm:trigger_incident(human_factions[i], "wh2_main_incident_intercontinental_diplomacy", true);
		end;
	end;
	if not max_distance then
		max_distance = 0;
	end;

	if not cm:get_saved_value("intercontinental_diplomacy_available") then
		cm:set_saved_value("intercontinental_diplomacy_available", max_distance);
		
		update_international_diplomacy_listener(max_distance);
	end;
	
	local region_list = cm:model():world():region_manager():region_list();
	
	-- make diplomacy available between owners of major port settlements within a distance
	if max_distance > 0 then
		for i = 0, region_list:num_items() - 1 do
			local current_region = region_list:item_at(i);
			
			if is_major_port(current_region) then
				local current_region_owner = current_region:owning_faction():name();

				if current_region_owner ~= "rebels" then
					local current_settlement = current_region:settlement();
					local current_settlement_pos_x = current_settlement:logical_position_x();
					local current_settlement_pos_y = current_settlement:logical_position_y();
					
					for j = 0, region_list:num_items() - 1 do
						local current_target_region = region_list:item_at(j);
						
						if is_major_port(current_target_region) then
							local current_target_settlement = current_target_region:settlement();
							local current_target_settlement_pos_x = current_target_settlement:logical_position_x();
							local current_target_settlement_pos_y = current_target_settlement:logical_position_y();
							
							if distance_squared(current_settlement_pos_x, current_settlement_pos_y, current_target_settlement_pos_x, current_target_settlement_pos_y) < max_distance then
								local current_target_region_owner = current_target_region:owning_faction():name();
								
								if current_region_owner ~= current_target_region_owner then
									cm:make_diplomacy_available(current_region_owner, current_target_region_owner);
								end;
							end;
						end;
					end;
				end
			end;
		end;
	-- make diplomacy available between owners of ALL major port settlements
	else
		local port_owners = {};					-- unsorted hashtable of port owners that we've added to port_owners_indexed
		local port_owners_indexed = {};			-- indexed list of the same data (it's unsafe to iterate over the unsorted hashtable in mp)
		
		for i = 0, region_list:num_items() - 1 do
			local current_region = region_list:item_at(i);
			
			if is_major_port(current_region) then
				local faction_name = current_region:owning_faction():name();
				
				if faction_name ~= "rebels" then
					-- iterate through our list to see if we already know that this faction owns a port
					-- we only want each cqi to be represented once and don't 
					if not port_owners[faction_name] then
						port_owners[faction_name] = true;
						table.insert(port_owners_indexed, faction_name);
					end;
				end
			end;
		end;
		
		for index, owner in ipairs(port_owners_indexed) do
			for index, target in ipairs(port_owners_indexed) do
				if owner ~= target then
					cm:make_diplomacy_available(owner, target);
				end;
			end;
		end;
	end;
end;

function is_major_port(region)
	return region:is_province_capital() and not region:is_abandoned() and region:settlement():is_port();
end;

function update_international_diplomacy_listener(max_distance)
	local autorun = true;
	
	local local_faction = cm:get_local_faction_name(true);
	
	if local_faction and cm:get_faction(local_faction) then
		autorun = false;
	end;

	-- if this is an autorun then call make_intercontinental_diplomacy_available() on every faction turn start, otherwise just do it when a human starts a turn
	local turn_start_listener_name;
	if autorun then
		turn_start_listener_name = "FactionTurnStart";
	else
		turn_start_listener_name = "ScriptEventHumanFactionTurnStart";
	end;
	
	core:add_listener(
		"update_intercontinental_diplomacy",
		turn_start_listener_name,
		true,
		function()
			make_intercontinental_diplomacy_available(false, max_distance);
		end,
		true
	);
end;

-- apply effect bundle to skaven forces laying siege if skaven corruption is high
function menace_below_monitor()
	core:add_listener(
		"menace_below_monitor",
		"PendingBattle",
		function()
			local pb = cm:model():pending_battle();
			local attacker = pb:attacker();
			local defender = pb:defender();
			
			return (attacker:faction():culture() == "wh2_main_skv_skaven" or defender:faction():culture() == "wh2_main_skv_skaven") and defender:has_region() and defender:region():religion_proportion("wh2_main_religion_skaven") >= 0.095;
		end,
		function()
			local pb = cm:model():pending_battle();
			local attacker = pb:attacker();
			local defender = pb:defender();
			local skaven_proportion = defender:region():religion_proportion("wh2_main_religion_skaven");
			local effect_bundle = "wh2_main_bundle_laying_siege_menace_below_corruption_bonus_"
			
			if skaven_proportion >= 0.655 then
				effect_bundle = effect_bundle .. "3";
			elseif skaven_proportion >= 0.325 then
				effect_bundle = effect_bundle .. "2";
			else
				effect_bundle = effect_bundle .. "1";
			end;
			
			local game_interface = cm:get_game_interface();
			
			if attacker:faction():culture() == "wh2_main_skv_skaven" then
				local attacker_cqi = attacker:cqi();
				
				remove_menace_below_effect_bundles(attacker_cqi)
				game_interface:apply_effect_bundle_to_characters_force(effect_bundle, attacker_cqi, 0, false);
			end;
			
			if defender:faction():culture() == "wh2_main_skv_skaven" then
				local defender_cqi = defender:cqi();
				
				remove_menace_below_effect_bundles(defender_cqi)
				game_interface:apply_effect_bundle_to_characters_force(effect_bundle, defender_cqi, 0, false);
			end;
		end,
		true
	);
	
	core:add_listener(
		"menace_below_cleanup",
		"BattleCompleted",
		function()
			local pb = cm:model():pending_battle();
			
			if pb:has_been_fought() then
				local attacker_cqi, attacker_force_cqi, attacker_faction_name = cm:pending_battle_cache_get_attacker(1);
				local defender_cqi, defender_force_cqi, defender_faction_name = cm:pending_battle_cache_get_defender(1);
				local attacker = cm:get_faction(attacker_faction_name);
				local defender = cm:get_faction(defender_faction_name);				
				
				return (attacker and attacker:culture() == "wh2_main_skv_skaven") or (defender and defender:culture() == "wh2_main_skv_skaven");
			else
				return (pb:has_attacker() and pb:attacker():faction():culture() == "wh2_main_skv_skaven") or (pb:has_defender() and pb:defender():faction():culture() == "wh2_main_skv_skaven");
			end;
		end,
		function()			
			local pb = cm:model():pending_battle();
			
			if pb:has_attacker() then
				remove_menace_below_effect_bundles(pb:attacker():cqi());
			end;
			
			if pb:has_defender() then
				remove_menace_below_effect_bundles(pb:defender():cqi());
			end;
		end,
		true
	);
end;

function remove_menace_below_effect_bundles(cqi)
	local effect_bundle = "wh2_main_bundle_laying_siege_menace_below_corruption_bonus_";
	local game_interface = cm:get_game_interface();
	
	for i = 1, 3 do
		game_interface:remove_effect_bundle_from_characters_force(effect_bundle .. tostring(i), cqi);
	end;
end;

-- scripted effect that reveals all sea regions
-- add any buildings or techs that use it here
local sea_region_effect_buildings = {
	"wh2_dlc11_special_dragon_tooth_lighthouse_1"
};

local sea_region_effect_techs = {
	"tech_hef_5_06"
};

function sea_region_shroud_effect_listener()
	core:add_listener(
		"sea_region_tech_listener",
		"ResearchCompleted",
		function(context)
			return context:faction():is_human() and sea_region_has_tech(context:faction());
		end,
		function(context)
			reveal_all_sea_regions(context:faction():name());
		end,
		true
	);
	
	core:add_listener(
		"sea_region_building_listener",
		"BuildingCompleted",
		function(context)
			return context:building():faction():is_human() and sea_region_has_constructed_building(context:building():name());
		end,
		function(context)
			reveal_all_sea_regions(context:building():faction():name());
		end,
		true
	);
	
	core:add_listener(
		"sea_region_faction_turn_start_listener",
		"ScriptEventHumanFactionTurnStart",
		function(context)
			local faction = context:faction();
			return sea_region_has_tech(faction) or sea_region_has_building(faction);
		end,
		function(context)
			reveal_all_sea_regions(context:faction():name());
		end,
		true
	);
end;

function sea_region_has_tech(faction)	
	for i = 1, #sea_region_effect_techs do
		 if faction:has_technology(sea_region_effect_techs[i]) then
			return true;
		end;
	end;
end;

function sea_region_has_constructed_building(building)
	for i = 1, #sea_region_effect_buildings do
		 if building == sea_region_effect_buildings[i] then
			return true;
		end;
	end;
end;

function sea_region_has_building(faction)
	local region_list = faction:region_list();
	
	for i = 0, region_list:num_items() - 1 do
		local current_region = region_list:item_at(i);
		
		for j = 1, #sea_region_effect_buildings do
			 if current_region:building_exists(sea_region_effect_buildings[j]) then
				return true;
			end;
		end;
	end;
end;

function reveal_all_sea_regions(faction_name)
	local regions = cm:model():world():sea_region_data();
	
	for i = 0, regions:num_items() - 1 do
		local current_region_name = regions:item_at(i):key();
		
		if not current_region_name:find("sea_lake") then
			cm:make_region_visible_in_shroud(faction_name, current_region_name);
		end;
	end;
end;







-- show the geomantic web help page when the geomantic web screen is opened
function show_geomantic_web_help_page_on_screen_open()
	core:add_listener(
		"show_geomantic_web_help_page_on_screen_open_listener",
		"ComponentLClickUp",
		function(context) return context.string == "button_geomantic_web" and UIComponent(UIComponent(context.component):Parent()):Id() == "button_group_management" end,
		function(context)
			local button_state = UIComponent(context.component):CurrentState();
			local hpm = get_help_page_manager();
			
			if (button_state == "down" and not hpm:is_panel_visible()) or (button_state == "selected_down" and hpm:is_panel_visible() and hpm:get_last_help_page() == "script_link_campaign_geomantic_web") then
				hp_geomantic_web:link_clicked();
			end;
		end,
		true
	);
end;




-- show an event when player performs scout ruins on a settlement that isn't owned by skaven
function show_target_ruins_success_event_message()
	core:add_listener(
		"show_target_ruins_success_event_message_listener",
		"CharacterGarrisonTargetAction",
		function(context)
			local agent_action_key = context:agent_action_key();
			
			return (agent_action_key:find("scout_settlement") or agent_action_key == "wh2_dlc09_agent_action_engineer_hinder_settlement_necrotect_ritual") and context:character():faction():is_human() and context:garrison_residence():faction():culture() ~= "wh2_main_skv_skaven";
		end,
		function(context)
			local settlement = context:garrison_residence():settlement_interface();
			local id = 900;
			local primary = "event_feed_strings_text_wh2_event_feed_string_scripted_event_scout_ruins_success_primary_detail";
			local secondary = "event_feed_strings_text_wh2_event_feed_string_scripted_event_scout_ruins_success_secondary_detail";
			local flavour = "event_feed_strings_text_wh2_event_feed_string_scripted_event_scout_ruins_success_flavour_text";
			
			if context:agent_action_key() == "wh2_dlc09_agent_action_engineer_hinder_settlement_necrotect_ritual" then
				id = 901;
				primary = "event_feed_strings_text_wh2_dlc09_event_feed_string_scripted_event_colonise_ruins_success_primary_detail";
				secondary = "event_feed_strings_text_wh2_dlc09_event_feed_string_scripted_event_colonise_ruins_success_secondary_detail";
				flavour = "event_feed_strings_text_wh2_dlc09_event_feed_string_scripted_event_colonise_ruins_success_flavour_text";
			end;
			
			cm:show_message_event_located(
				context:character():faction():name(),
				primary,
				secondary,
				flavour,
				settlement:logical_position_x(),
				settlement:logical_position_y(),
				true,
				id
			);
		end,
		true
	);
end;



function disable_tax_and_public_order_for_regions(regions)
	for i = 1, #regions do
		cm:exempt_province_from_tax_for_all_factions_and_set_default(regions[i], true);
		cm:set_public_order_disabled_for_province_for_region_for_all_factions_and_set_default(regions[i], true);
	end;
end;



-- apply an effect bundle to a human beastmen faction when positive diplomatic event occurs
function beastmen_positive_diplomatic_event_listener()
	core:add_listener(
		"beastmen_positive_diplomatic_event",
		"PositiveDiplomaticEvent",
		true,
		function(context)
			local function apply_diplomatic_effect_bundle(faction_name, context)
				if context:is_alliance() then
					cm:apply_effect_bundle("wh_dlc03_bundle_beastmen_alliance_made", faction_name, 5);
				elseif context:is_peace_treaty() then
					cm:apply_effect_bundle("wh_dlc03_bundle_beastmen_peace_made", faction_name, 5);
				elseif context:is_non_aggression_pact() then
					cm:apply_effect_bundle("wh_dlc03_bundle_beastmen_non_aggression_made", faction_name, 5);
				end
			end
			
			local proposer = context:proposer();
			local recipient = context:recipient();
			
			if proposer:is_human() and proposer:culture() == "wh_dlc03_bst_beastmen" then
				apply_diplomatic_effect_bundle(proposer:name(), context);
			end
			
			if recipient:is_human() and recipient:culture() == "wh_dlc03_bst_beastmen" then
				apply_diplomatic_effect_bundle(recipient:name(), context);
			end
		end,
		true
	);
end;


function wh_faction_is_horde(faction)
	return faction:is_allowed_to_capture_territory() == false;
end;
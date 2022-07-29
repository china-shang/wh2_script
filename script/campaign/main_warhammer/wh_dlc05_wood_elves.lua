WOOD_ELF_FACTIONS = {"wh_dlc05_wef_wood_elves", "wh_dlc05_wef_argwylon", "wh_dlc05_wef_wydrioth", "wh_dlc05_wef_torgovann"};
OAK_OF_AGES_REGION = "wh_main_yn_edri_eternos_the_oak_of_ages";
BEASTMEN_INVASION_FACTION = "wh_dlc03_bst_beastmen";
OAK_INVASION_LEVEL = 0;
OAK_INVASION_TURN = -1;
WILD_HUNT_NEXT_AVAILABLE = 10;
WILD_HUNT_END_TURN = -1;
WILD_HUNT_FACTION = "";
WILD_HUNT_LASTS = 10;
WILD_HUNT_COOLDOWN = 20;
WEF_PERSONALITY_TIMER = 60;
WEF_PERSONALITY_KEY = "wh_dlc05_wood_elves_default_main";
MINISTERIAL_POSITION_BUNDLES = {
	["faction_leader"] = "wh_dlc05_minister_wef_elf_faction_leader_active_hunt",
	["wh_dlc05_minister_wef_elf_elder_speaker"] = "wh_dlc05_minister_wef_elf_talon_of_kurnous_active_hunt",
	["wh_dlc05_minister_wef_elf_herald_of_the_hunt"] = "wh_dlc05_minister_wef_elf_herald_of_the_hunt_active_hunt",
	["wh_dlc05_minister_wef_elf_protector_of_the_oak"] = "wh_dlc05_minister_wef_elf_spirit_of_the_hunt_active_hunt",
	["wh_dlc05_minister_wef_elf_starlight_craftsman"] = "wh_dlc05_minister_wef_elf_master_of_supplies_active_hunt",
	["wh_dlc05_minister_wef_elf_the_tricksters_masque"] = "wh_dlc05_minister_wef_elf_master_of_drums_active_hunt",
	["wh_dlc05_minister_wef_elf_warden_of_the_wildwood"] = "wh_dlc05_minister_wef_elf_master_of_scouts_active_hunt",

}

MAIN_WOODELVES = {
	"wh2_dlc16_wef_drycha",
	"wh2_dlc16_wef_sisters_of_twilight",
	"wh_dlc05_wef_argwylon",
	"wh_dlc05_wef_wood_elves"
}
WEF_PERSONALITY_KEY_MAIN = "wh_dlc05_wood_elves_default_main"

SECONDARY_WOODELVES = {
	"wh2_dlc13_wef_laurelorn_forest",
	"wh2_main_wef_bowmen_of_oreon",
	"wh_dlc05_wef_torgovann",
	"wh_dlc05_wef_wydrioth"
}
WEF_PERSONALITY_KEY_SECONDARY = "wh_dlc05_wood_elves_default_secondary"

function Add_Wood_Elves_Listeners()
	out("#### Adding Wood Elves Listeners ####");

	MP_personality_setup_wef();

	-- start a FactionTurnStart listener for each Wood Elf faction
	for i = 1, #WOOD_ELF_FACTIONS do
		cm:add_faction_turn_start_listener_by_name(
			"WoodElves_FactionTurnStart",
			WOOD_ELF_FACTIONS[i],
			WoodElves_FactionTurnStart,
			true
		);
	end;
	
	if not cm:is_multiplayer() then
		if cm:is_new_game() then
			oak_invasion_intervention:start();
		end
		
	
		core:add_listener(
			"WoodElves_MissionSucceeded",
			"MissionSucceeded",
			true,
			function(context) WoodElves_MissionSucceeded(context) end,
			true
		);
		
		-- Create the Beastmen Invasion Manager Spawns
		invasion_manager:new_spawn_location("beastmen_spawn_1", 424, 369); -- Main Location
		invasion_manager:new_spawn_location("beastmen_spawn_2", 433, 366);
		invasion_manager:new_spawn_location("beastmen_spawn_3", 411, 372);
		invasion_manager:new_spawn_location("beastmen_spawn_4", 443, 362);
		
		invasion_manager:new_spawn_location("beastmen_spawn_5", 425, 349); -- Middle Outcrop
		invasion_manager:new_spawn_location("beastmen_spawn_6", 432, 348);
		
		invasion_manager:new_spawn_location("beastmen_spawn_7", 428, 391); -- Northern Outcrop
		invasion_manager:new_spawn_location("beastmen_spawn_8", 437, 384);
		
		invasion_manager:new_spawn_location("beastmen_spawn_9", 425, 349); -- Southern Outcrop
		invasion_manager:new_spawn_location("beastmen_spawn_10", 422, 293);
		
		invasion_manager:new_spawn_location("beastmen_spawn_estalia", 382, 278); -- Estalia Forest
		
		random_army_manager:new_force("beastmen_force_raid");
		random_army_manager:add_mandatory_unit("beastmen_force_raid", "wh_dlc03_bst_inf_ungor_herd_1", 4);
		random_army_manager:add_mandatory_unit("beastmen_force_raid", "wh_dlc03_bst_inf_gor_herd_0", 2);
		random_army_manager:add_mandatory_unit("beastmen_force_raid", "wh_dlc03_bst_inf_ungor_raiders_0", 2);
		random_army_manager:add_mandatory_unit("beastmen_force_raid", "wh_dlc03_bst_inf_chaos_warhounds_0", 2);
		random_army_manager:add_unit("beastmen_force_raid", "wh_dlc03_bst_inf_ungor_herd_1", 2);
		random_army_manager:add_unit("beastmen_force_raid", "wh_dlc03_bst_inf_ungor_raiders_0", 1);
		
		random_army_manager:new_force("beastmen_force_easy");
		random_army_manager:add_mandatory_unit("beastmen_force_easy", "wh_dlc03_bst_inf_ungor_herd_1", 4);
		random_army_manager:add_mandatory_unit("beastmen_force_easy", "wh_dlc03_bst_inf_gor_herd_0", 2);
		random_army_manager:add_mandatory_unit("beastmen_force_easy", "wh_dlc03_bst_inf_gor_herd_1", 2);
		random_army_manager:add_mandatory_unit("beastmen_force_easy", "wh_dlc03_bst_inf_ungor_raiders_0", 2);
		random_army_manager:add_unit("beastmen_force_easy", "wh_dlc03_bst_inf_minotaurs_0", 1);
		random_army_manager:add_unit("beastmen_force_easy", "wh_dlc03_bst_inf_minotaurs_1", 1);
		random_army_manager:add_unit("beastmen_force_easy", "wh_dlc03_bst_inf_minotaurs_2", 1);
		random_army_manager:add_unit("beastmen_force_easy", "wh_dlc03_bst_inf_razorgor_herd_0", 1);
		random_army_manager:add_unit("beastmen_force_easy", "wh_dlc03_bst_inf_cygor_0", 1);
		random_army_manager:add_unit("beastmen_force_easy", "wh_dlc03_bst_inf_bestigor_herd_0", 1);
		random_army_manager:add_unit("beastmen_force_easy", "wh_dlc03_bst_inf_centigors_0", 1);
		random_army_manager:add_unit("beastmen_force_easy", "wh_dlc03_bst_inf_centigors_1", 1);
		random_army_manager:add_unit("beastmen_force_easy", "wh_dlc03_bst_inf_centigors_2", 1);
		
		random_army_manager:new_force("beastmen_force_normal");
		random_army_manager:add_mandatory_unit("beastmen_force_normal", "wh_dlc03_bst_inf_gor_herd_0", 4);
		random_army_manager:add_mandatory_unit("beastmen_force_normal", "wh_dlc03_bst_inf_gor_herd_1", 4);
		random_army_manager:add_mandatory_unit("beastmen_force_normal", "wh_dlc03_bst_inf_ungor_raiders_0", 2);
		random_army_manager:add_unit("beastmen_force_normal", "wh_dlc03_bst_inf_minotaurs_0", 1);
		random_army_manager:add_unit("beastmen_force_normal", "wh_dlc03_bst_inf_minotaurs_1", 1);
		random_army_manager:add_unit("beastmen_force_normal", "wh_dlc03_bst_inf_minotaurs_2", 1);
		random_army_manager:add_unit("beastmen_force_normal", "wh_dlc03_bst_inf_razorgor_herd_0", 1);
		random_army_manager:add_unit("beastmen_force_normal", "wh_dlc03_bst_inf_cygor_0", 1);
		random_army_manager:add_unit("beastmen_force_normal", "wh_dlc03_bst_inf_bestigor_herd_0", 1);
		random_army_manager:add_unit("beastmen_force_normal", "wh_dlc03_bst_inf_centigors_0", 1);
		random_army_manager:add_unit("beastmen_force_normal", "wh_dlc03_bst_inf_centigors_1", 1);
		random_army_manager:add_unit("beastmen_force_normal", "wh_dlc03_bst_inf_centigors_2", 1);
		
		random_army_manager:new_force("beastmen_force_hard");
		random_army_manager:add_mandatory_unit("beastmen_force_hard", "wh_dlc03_bst_inf_gor_herd_0", 2);
		random_army_manager:add_mandatory_unit("beastmen_force_hard", "wh_dlc03_bst_inf_gor_herd_1", 2);
		random_army_manager:add_mandatory_unit("beastmen_force_hard", "wh_dlc03_bst_inf_bestigor_herd_0", 4);
		random_army_manager:add_mandatory_unit("beastmen_force_hard", "wh_dlc03_bst_inf_ungor_raiders_0", 2);
		random_army_manager:add_unit("beastmen_force_hard", "wh_dlc03_bst_inf_minotaurs_0", 1);
		random_army_manager:add_unit("beastmen_force_hard", "wh_dlc03_bst_inf_minotaurs_1", 1);
		random_army_manager:add_unit("beastmen_force_hard", "wh_dlc03_bst_inf_minotaurs_2", 1);
		random_army_manager:add_unit("beastmen_force_hard", "wh_dlc03_bst_inf_razorgor_herd_0", 1);
		random_army_manager:add_unit("beastmen_force_hard", "wh_dlc03_bst_inf_cygor_0", 1);
		random_army_manager:add_unit("beastmen_force_hard", "wh_dlc03_bst_inf_bestigor_herd_0", 1);
		random_army_manager:add_unit("beastmen_force_hard", "wh_dlc03_bst_inf_centigors_0", 1);
		random_army_manager:add_unit("beastmen_force_hard", "wh_dlc03_bst_inf_centigors_1", 1);
		random_army_manager:add_unit("beastmen_force_hard", "wh_dlc03_bst_inf_centigors_2", 1);
	end
	
	-- No Tax or PO for the Oak
	cm:exempt_province_from_tax_for_all_factions_and_set_default(OAK_OF_AGES_REGION, true);
	cm:set_public_order_disabled_for_province_for_region_for_all_factions_and_set_default(OAK_OF_AGES_REGION, true);
	
	core:add_listener(
		"WoodElves_SettlementSelected",
		"SettlementSelected",
		true,
		function(context) WoodElves_SettlementSelected(context) end,
		true
	);
end

function MP_personality_setup_wef()

	if cm:is_multiplayer() == true then
		local player_faction = cm:get_human_factions();

		for i = 1, #player_faction do
			if cm:get_faction(player_faction[i]):subculture() == "wh_dlc05_sc_wef_wood_elves" then
				for i = 1, #MAIN_WOODELVES do
					cm:force_change_cai_faction_personality(MAIN_WOODELVES[i], WEF_PERSONALITY_KEY_MAIN);
				end
				for i = 1, #SECONDARY_WOODELVES do
					cm:force_change_cai_faction_personality(SECONDARY_WOODELVES[i], WEF_PERSONALITY_KEY_SECONDARY);
				end
			end
		end
	end
end

function WoodElves_FactionTurnStart(context)
	local faction = context:faction();
	local faction_name = faction:name();
	local is_human = faction:is_human();
	local human_factions = cm:get_human_factions();
	
	--[[
	-- Wood Elves cannot confederate (until the Oak of Ages is constructed)
	cm:force_diplomacy("faction:" .. faction_name, "culture:wh_dlc05_wef_wood_elves", "form confederation", false, false, false);
	
	-- Check if Oak of Ages level 3 exists, then permit confederation
	local oak_region = cm:get_region(OAK_OF_AGES_REGION);
		
	if oak_region and not oak_region:is_abandoned() and (oak_region:owning_faction():is_human() or cm:model():turn_number() >= 90) and oak_region:owning_faction() == faction and Get_Oak_Of_Ages_Level() >= 3 then
		cm:force_diplomacy("faction:" .. faction_name, "culture:wh_dlc05_wef_wood_elves", "form confederation", true, false, false);
	end
	]]--
	
	-- A.I Wood Elves cannot declare war on other Wood Elves / Cannot offer trade (but will accept)
	if not is_human then
		cm:force_diplomacy("faction:" .. faction_name, "culture:wh_dlc05_wef_wood_elves", "war", false, false, false);
	end
	
	-- Wood Elves Trade Check
	
	-- Check if Wild Hunt needs triggering
	if faction_name == "wh_dlc05_wef_wood_elves" then
		Process_Wild_Hunt(faction);
	end
	
	-- No BM invasions in MP
	if not cm:is_multiplayer() and is_human then
		Check_Oak_Invasions(faction);
	end
	
	if faction_name == "wh_dlc05_wef_wood_elves" and not is_human then
		WEF_PERSONALITY_TIMER = WEF_PERSONALITY_TIMER - 1;
	
		if WEF_PERSONALITY_TIMER < 1 then
			if WEF_PERSONALITY_KEY == "wh_dlc05_wood_elves_default_main" then -- DEFENSIVE
				-- Going offensive
				WEF_PERSONALITY_TIMER = 10;
				WEF_PERSONALITY_KEY = "wh_dlc05_wood_elves_default_main_aggressive";

				for i = 1, #human_factions do
					cm:show_message_event(
						human_factions[i],
						"event_feed_strings_text_wh_dlc05_event_feed_string_scripted_event_wild_hunt_start_title",
						"event_feed_strings_text_wh_dlc05_event_feed_string_scripted_event_wild_hunt_start_primary_detail",
						"event_feed_strings_text_wh2_dlc16_event_feed_string_scripted_event_wild_hunt_start_secondary_detail_ai",
						true,
						556
					);
				end
			elseif WEF_PERSONALITY_KEY == "wh_dlc05_wood_elves_default_main_aggressive" then -- OFFENSIVE
				-- Going defensive
				WEF_PERSONALITY_TIMER = 50;
				WEF_PERSONALITY_KEY = "wh_dlc05_wood_elves_default_main";

				for i = 1, #human_factions do
					cm:show_message_event(
						human_factions[i],
						"event_feed_strings_text_wh_dlc05_event_feed_string_scripted_event_wild_hunt_end_title",
						"event_feed_strings_text_wh_dlc05_event_feed_string_scripted_event_wild_hunt_end_primary_detail",
						"event_feed_strings_text_wh_dlc05_event_feed_string_scripted_event_wild_hunt_end_secondary_detail",
						true,
						556
					);
				end
			end
			
			-- Change the personality
			out("Wood Elves AI: Changing Wood Elves personality to "..WEF_PERSONALITY_KEY.." for "..WEF_PERSONALITY_TIMER.." turns");
			cm:force_change_cai_faction_personality(faction_name, WEF_PERSONALITY_KEY);
		end
	end
	
end

function WoodElves_SettlementSelected(context)
	local region = context:garrison_residence():region();
	
	if not region:is_null_interface() then
		local uim = cm:get_campaign_ui_manager();
		
		if region:name() == OAK_OF_AGES_REGION then
			uim:override("tax_exemption"):set_allowed(false);
			return nil;
		end
		uim:override("tax_exemption"):set_allowed(true);
	end
end

---- OAK OF AGES INVASION ----
oak_invasion_intervention = intervention:new(
	"oak_invasion_intervention",
	0,
	function() Start_Beastmen_Oak_Invasion() end,
	BOOL_INTERVENTIONS_DEBUG
);

oak_invasion_intervention:add_trigger_condition(
	"BuildingConstructionIssuedByPlayer",
	function(context)
		local faction_name = context:garrison_residence():faction():name();

		if Is_Wood_Elf(faction_name) then
			if context:building() == "wh_dlc05_wef_oak_of_ages_5" then
				return true;
			end
		end
		return false;
	end
);

oak_invasion_intervention:set_suppress_pause_before_triggering(true);
oak_invasion_intervention:set_wait_for_event_dismissed(false);

function Start_Beastmen_Oak_Invasion()
	local region = cm:get_region(OAK_OF_AGES_REGION);
	
	if region and not region:is_abandoned() and region:owning_faction():is_human() then
		local faction = region:owning_faction();
		local faction_name = faction:name();
		OAK_INVASION_TURN = cm:model():turn_number();

		local force_easy = random_army_manager:generate_force("beastmen_force_easy", 20, false);
		local force_normal = random_army_manager:generate_force("beastmen_force_normal", 20, false);
		local force_hard = random_army_manager:generate_force("beastmen_force_hard", 20, false);
		
		local invasion_1 = invasion_manager:new_invasion("beastmen_invasion_1", BEASTMEN_INVASION_FACTION, force_hard, "beastmen_spawn_1");
		invasion_1:set_target("REGION", OAK_OF_AGES_REGION, faction_name);
		invasion_1:apply_effect("wh_main_bundle_military_upkeep_free_force", -1);
		invasion_1:start_invasion(
		function(self)
			local force_leader = self:get_general();
			local region_key = force_leader:region():name();
			
			for i = 1, #WOOD_ELF_FACTIONS do
				cm:make_region_visible_in_shroud(WOOD_ELF_FACTIONS[i], region_key);
			end
			
			cm:show_advice("dlc05.camp.advice.wef.invasion.001");
			cm:scroll_camera_from_current(false, 6, {force_leader:display_position_x(), force_leader:display_position_y(), 14.768, 0.0, 12.0});
			Beastmen_Attack_War_Declarations();
		end
		);
		
		-- This one is going to attack the players capital
		local fac_capital = faction:home_region():name();
		local invasion_2 = invasion_manager:new_invasion("beastmen_invasion_2", BEASTMEN_INVASION_FACTION, force_normal, "beastmen_spawn_2");
		invasion_2:set_target("REGION", fac_capital, faction_name);
		invasion_2:apply_effect("wh_main_bundle_military_upkeep_free_force", -1);
		invasion_2:start_invasion();
		
		local invasion_3 = invasion_manager:new_invasion("beastmen_invasion_3", BEASTMEN_INVASION_FACTION, force_easy, "beastmen_spawn_3");
		
		if faction:has_faction_leader() and faction:faction_leader():has_military_force() then
			invasion_3:set_target("CHARACTER", faction:faction_leader():command_queue_index(), faction_name);
		else
			invasion_3:set_target("REGION", OAK_OF_AGES_REGION, faction_name);
		end
		invasion_3:apply_effect("wh_main_bundle_military_upkeep_free_force", -1);
		invasion_3:start_invasion();
		
		oak_invasion_intervention:complete();
	end
end

function Beastmen_Attack_War_Declarations()
	cm:force_declare_war("wh_dlc03_bst_beastmen", "wh_dlc05_wef_wood_elves", true, true);
	cm:force_declare_war("wh_dlc03_bst_beastmen", "wh_dlc05_wef_argwylon", true, true);
end


function WoodElves_MissionSucceeded(context)
	if context:mission():mission_record_key() == "wh_dlc05_qb_wef_grand_defense_of_the_oak" then
		-- This turns off the invasions when you win the final quest battle
		OAK_INVASION_TURN = -1;
		
		-- Kill the remaining Beastmen
		local faction = cm:get_faction(BEASTMEN_INVASION_FACTION);
		
		if faction then
			local mf_list = faction:military_force_list();
			
			for i = 0, mf_list:num_items() - 1 do
				local current_mf = mf_list:item_at(i);
				
				if not current_mf:is_null_interface() and current_mf:has_general() then
					cm:kill_character(current_mf:general_character():command_queue_index(), true, true);
				end
			end
		end
		
		cm:complete_scripted_mission_objective("wh_main_long_victory", "delay_victory", true);
	end
end

function Check_Oak_Invasions(faction)
	out("Check_Oak_Invasions("..faction:name()..")");
	local region = cm:get_region(OAK_OF_AGES_REGION);
	local region_count = faction:region_list():num_items();
	local turn_number = cm:model():turn_number();
	
	if region and not region:is_abandoned() and region:owning_faction():name() == faction:name() then
		if region_count >= 5 and OAK_INVASION_LEVEL == 0 then
			OAK_INVASION_LEVEL = 1;
			local force = random_army_manager:generate_force("beastmen_force_easy", 20, false);
			local invasion = invasion_manager:new_invasion("beastmen_tree_attack_2", BEASTMEN_INVASION_FACTION, force, "beastmen_spawn_estalia");
			invasion:set_target("REGION", OAK_OF_AGES_REGION, faction_name);
			invasion:apply_effect("wh_main_bundle_military_upkeep_free_force", -1);
			invasion:start_invasion(Beastmen_Attack_War_Declarations);
		elseif region_count >= 10 and OAK_INVASION_LEVEL == 1 then
			OAK_INVASION_LEVEL = 2;
			local force = random_army_manager:generate_force("beastmen_force_normal", 20, false);
			local invasion = invasion_manager:new_invasion("beastmen_tree_attack_3", BEASTMEN_INVASION_FACTION, force, "beastmen_spawn_estalia");
			invasion:set_target("REGION", OAK_OF_AGES_REGION, faction_name);
			invasion:apply_effect("wh_main_bundle_military_upkeep_free_force", -1);
			invasion:start_invasion(Beastmen_Attack_War_Declarations);
		elseif region_count >= 18 and OAK_INVASION_LEVEL == 2 then
			OAK_INVASION_LEVEL = 3;
			local force = random_army_manager:generate_force("beastmen_force_hard", 20, false);
			local invasion = invasion_manager:new_invasion("beastmen_tree_attack_4", BEASTMEN_INVASION_FACTION, force, "beastmen_spawn_estalia");
			invasion:set_target("REGION", OAK_OF_AGES_REGION, faction_name);
			invasion:apply_effect("wh_main_bundle_military_upkeep_free_force", -1);
			invasion:start_invasion(Beastmen_Attack_War_Declarations);
		end
		
		if OAK_INVASION_TURN > -1 then
			if turn_number == (OAK_INVASION_TURN + 3) then
				OAK_INVASION_TURN = turn_number;
				local inv_spawn = cm:random_number(9) + 1;
				local force = random_army_manager:generate_force("beastmen_force_normal", 20, false);
				local invasion = invasion_manager:new_invasion("beastmen_tree_attack_"..turn_number.."_"..inv_spawn, BEASTMEN_INVASION_FACTION, force, "beastmen_spawn_"..inv_spawn);
				invasion:set_target("REGION", OAK_OF_AGES_REGION, faction_name);
				invasion:apply_effect("wh_main_bundle_military_upkeep_free_force", -1);
				invasion:start_invasion(Beastmen_Attack_War_Declarations);
			end
		end
	end
end


function Is_Wood_Elf(faction_key)
	for i = 1, #WOOD_ELF_FACTIONS do
		if WOOD_ELF_FACTIONS[i] == faction_key then
			return true;
		end
	end
	return false;
end

function Get_Oak_Of_Ages_Level()
	local oak_region = cm:get_region(OAK_OF_AGES_REGION);
		
	if oak_region then
		if oak_region:building_exists("wh_dlc05_wef_oak_of_ages_1") then
			return 1;
		elseif oak_region:building_exists("wh_dlc05_wef_oak_of_ages_2") then
			return 2;
		elseif oak_region:building_exists("wh_dlc05_wef_oak_of_ages_3") then
			return 3;
		elseif oak_region:building_exists("wh_dlc05_wef_oak_of_ages_4") then
			return 4;
		elseif oak_region:building_exists("wh_dlc05_wef_oak_of_ages_5") then
			return 5;
		end
	end
	return 0;
end

function Process_Wild_Hunt(faction)
	local turn_number = cm:model():turn_number();
	
	if turn_number == WILD_HUNT_END_TURN and WILD_HUNT_FACTION == faction:name() then
		Wild_Hunt_Ends(WILD_HUNT_FACTION);
		WILD_HUNT_END_TURN = -1;
		return nil;
	end
	
	-- Enough time passed since the last Wild Hunt?
	if turn_number >= WILD_HUNT_NEXT_AVAILABLE then
		if faction:faction_leader():has_military_force() then
			Trigger_Wild_Hunt();
			WILD_HUNT_NEXT_AVAILABLE = turn_number + WILD_HUNT_COOLDOWN;
			WILD_HUNT_END_TURN = turn_number + WILD_HUNT_LASTS;
			WILD_HUNT_FACTION = faction:name();
		end
	end
end

function Trigger_Wild_Hunt()
	local orion_faction = cm:get_faction("wh_dlc05_wef_wood_elves")
	local char_list = orion_faction:character_list();
	local orion = orion_faction:faction_leader()

	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);

		---loop through all office-holders and apply the appropriate bundle
		if not current_char:is_null_interface() and is_string(MINISTERIAL_POSITION_BUNDLES[current_char:ministerial_position()]) and current_char:has_military_force()then
			cm:apply_effect_bundle_to_character(MINISTERIAL_POSITION_BUNDLES[current_char:ministerial_position()], current_char, WILD_HUNT_LASTS + 1);
		end
	end
 
	cm:trigger_incident("wh_dlc05_wef_wood_elves", "wh2_dlc16_incident_wef_wild_hunt_begins", true)
end

function Wild_Hunt_Ends(faction)
	cm:trigger_incident("wh_dlc05_wef_wood_elves", "wh2_dlc16_incident_wef_wild_hunt_ends", true)
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("OAK_INVASION_LEVEL", OAK_INVASION_LEVEL, context);
		cm:save_named_value("OAK_INVASION_TURN", OAK_INVASION_TURN, context);
		cm:save_named_value("WILD_HUNT_NEXT_AVAILABLE", WILD_HUNT_NEXT_AVAILABLE, context);
		cm:save_named_value("WILD_HUNT_END_TURN", WILD_HUNT_END_TURN, context);
		cm:save_named_value("WILD_HUNT_FACTION", WILD_HUNT_FACTION, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		OAK_INVASION_LEVEL = cm:load_named_value("OAK_INVASION_LEVEL", 0, context);
		OAK_INVASION_TURN = cm:load_named_value("OAK_INVASION_TURN", -1, context);
		if not cm:is_new_game() then
			WILD_HUNT_NEXT_AVAILABLE = cm:load_named_value("WILD_HUNT_NEXT_AVAILABLE", WILD_HUNT_NEXT_AVAILABLE, context);
		end
		WILD_HUNT_END_TURN = cm:load_named_value("WILD_HUNT_END_TURN", -1, context);
		WILD_HUNT_FACTION = cm:load_named_value("WILD_HUNT_FACTION", "", context);
	end
);
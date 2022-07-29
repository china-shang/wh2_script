local wh2_dlc15_athel_tamarha_mist_1 = false;
local wh2_dlc15_athel_tamarha_mist_2 = false;
local wh2_dlc15_athel_tamarha_mist_3 = false;
local flushed = false;
local eltharion_faction_string = "wh2_main_hef_yvresse"

-- regions to apply mist to
moy = {}
moy.level_1_regions = {
	["main_warhammer"] = {
		"wh2_main_yvresse_tor_yvresse"
	},
	["wh2_main_great_vortex"] = {
		"wh2_main_vor_northern_yvresse_tor_yvresse"
	}
};
moy.level_2_regions = {
	["main_warhammer"] = {
		"wh2_main_yvresse_tor_yvresse",
		"wh2_main_yvresse_elessaeli",
		"wh2_main_yvresse_tralinia",
		"wh2_main_yvresse_shrine_of_loec"
	},
	["wh2_main_great_vortex"] = {
		"wh2_main_vor_northern_yvresse_sardenath",
		"wh2_main_vor_northern_yvresse_tor_yvresse",
		"wh2_main_vor_northern_yvresse_tralinia",
		"wh2_main_vor_southern_yvresse_elessaeli",
		"wh2_main_vor_southern_yvresse_shrine_of_loec",
		"wh2_main_vor_southern_yvresse_cairn_thel"
	}
};
moy.level_3_regions = {
	["main_warhammer"] = {
		"wh2_main_caledor_vauls_anvil",
		"wh2_main_caledor_tor_sethai",
		"wh2_main_tiranoc_whitepeak",
		"wh2_main_tiranoc_tor_anroc",
		"wh2_main_nagarythe_tor_dranil",
		"wh2_main_nagarythe_tor_anlec",
		"wh2_main_nagarythe_shrine_of_khaine",
		"wh2_main_chrace_tor_achare",
		"wh2_main_chrace_elisia",
		"wh2_main_cothique_mistnar",
		"wh2_main_cothique_tor_koruali",
		"wh2_main_yvresse_tor_yvresse",
		"wh2_main_yvresse_elessaeli",
		"wh2_main_yvresse_tralinia",
		"wh2_main_yvresse_shrine_of_loec"
	},
	["wh2_main_great_vortex"] = {
		"wh2_main_vor_straits_of_lothern_glittering_tower",
		"wh2_main_vor_caledor_vauls_anvil",
		"wh2_main_vor_caledor_caledors_repose",
		"wh2_main_vor_caledor_tor_sethai",
		"wh2_main_vor_tiranoc_whitepeak",
		"wh2_main_vor_tiranoc_tor_anroc",
		"wh2_main_vor_tiranoc_the_high_vale",
		"wh2_main_vor_tiranoc_salvation_isle",
		"wh2_main_vor_nagarythe_tor_dranil",
		"wh2_main_vor_nagarythe_tor_anlec",
		"wh2_main_vor_nagarythe_shrine_of_khaine",
		"wh2_main_vor_chrace_tor_gard",
		"wh2_main_vor_chrace_tor_achare",
		"wh2_main_vor_chrace_elisia",
		"wh2_main_vor_cothique_tor_koruali",
		"wh2_main_vor_cothique_mistnar",
		"wh2_main_vor_northern_yvresse_sardenath",
		"wh2_main_vor_northern_yvresse_tor_yvresse",
		"wh2_main_vor_northern_yvresse_tralinia",
		"wh2_main_vor_southern_yvresse_elessaeli",
		"wh2_main_vor_southern_yvresse_shrine_of_loec",
		"wh2_main_vor_southern_yvresse_cairn_thel"
	}
};

function add_eltharion_mist_listeners()

	moy:update_mists_of_yvresse() -- update straight away so mists persist when saving/loading

	out("#### Adding Eltharion Mist Listeners ####");
	-- Determine which level of the athel tamarha mist ritual is unlocked
	core:add_listener(
		"mist_ritual_unlock",
		"RitualCompletedEvent",
		true,
		function(context)
			if context:ritual():ritual_key() == "wh2_dlc15_athel_tamarha_mist_3" then
				wh2_dlc15_athel_tamarha_mist_3 = true
			elseif context:ritual():ritual_key() == "wh2_dlc15_athel_tamarha_mist_2" then
				wh2_dlc15_athel_tamarha_mist_2 = true
			elseif context:ritual():ritual_key() == "wh2_dlc15_athel_tamarha_mist_1" then
				wh2_dlc15_athel_tamarha_mist_1 = true
			end
		end,	
		true
	);
	--Purge the mists if Eltharion is dead
	local function start_eltharion_dead_check()
		core:add_listener(
			"mist_of_yvresse_monitor",
			"FactionTurnStart",
			function()
				return cm:get_faction(eltharion_faction_string):is_dead();
			end,
			function(context)
				moy:purge_mists_of_yvresse();
				cm:set_saved_value("eltharion_faction_is_dead", true);
			end,
			false		-- this listener stops when it triggers
		);
	end;
	
	-- Only start the eltharion-dead-check listener on script start if the faction is not thought to be dead
	if not cm:get_saved_value("eltharion_faction_is_dead") then
		start_eltharion_dead_check();
	end;

	-- Update the mists at the start of Yvresse's turn
	cm:add_faction_turn_start_listener_by_name(
		"mist_of_yvresse_monitor",
		eltharion_faction_string,
		function(context)
			if context:faction():has_pooled_resource("yvresse_defence") == true then
				
				-- if the eltharion-is thought to be dead check listener is not running then start it (eltharion's faction has come back to life?)
				if cm:get_saved_value("eltharion_faction_is_dead") then
					cm:set_saved_value("eltharion_faction_is_dead", false);
					start_eltharion_dead_check();
				end;
				moy:update_mists_of_yvresse();
			end
		end,
		true
	);

	--- listen for the Rite of Ladrielle/Athel Tamarha rituals and force an update so boosted effects appear immediately
	core:add_listener(
		"mist_ritual_unlock",
		"RitualCompletedEvent",
		function(context) 
			local ritual_key = context:ritual():ritual_key()
			if ritual_key == "wh2_dlc15_ritual_hef_ladrielle" or string.match(ritual_key,"wh2_dlc15_athel_tamarha_mist_.*") then
			return true	
			end
		end,
		function(context)
			moy:update_mists_of_yvresse();
		end,
		true
	);


	---- Update every time Eltharion occupies/loses a settlement
	core:add_listener(
		"mist_region_captured_update",
		"GarrisonOccupiedEvent",
		function(context) 
			local occupying_faction = context:garrison_residence():faction()
			local occupied_faction = context:character():faction()
			if occupying_faction:name() == eltharion_faction_string or occupied_faction:name() == eltharion_faction_string then
				return true	
			end
		end,
		function(context)
			moy:update_mists_of_yvresse();
		end,
		true
	);

	--- update when the Yvresse Defence level increases
	core:add_listener(
		"mist_yvresse_defence_update",
		"PooledResourceEffectChangedEvent",
		function(context) 
			return context:resource():key() == "yvresse_defence"
		end,
		function(context)
			moy:update_mists_of_yvresse();
		end,
		true
	);

	
end



---- purge existing mist, then check which regions should be misty and loop through them to apply effects
function moy:update_mists_of_yvresse()
	moy:purge_mists_of_yvresse()
	
	local campaign = cm:get_campaign_name()
	local yvresse_faction = cm:model():world():faction_by_key("wh2_main_hef_yvresse");
	local yvresse_defence = cm:get_faction(eltharion_faction_string):pooled_resource("yvresse_defence"):value();

	out("wh2_dlc15_eltharion_mist: updating Mists of Yvresse regional effect bundles")
	if yvresse_defence >= 25 and yvresse_defence <= 49 then
		for i=1, #moy.level_1_regions[campaign] do
			local region = moy.level_1_regions[campaign][i];
			core:trigger_event("ScriptEventYvresseDefenceOne");
			moy:apply_mists_of_yvresse_effects(region)
		end
	elseif yvresse_defence >= 50 and yvresse_defence <= 74 then
		for i=1, #moy.level_2_regions[campaign] do
			local region = moy.level_2_regions[campaign][i];
			core:trigger_event("ScriptEventYvresseDefenceTwo");
			moy:apply_mists_of_yvresse_effects(region)
		end
	elseif yvresse_defence >= 75 and yvresse_faction:is_human() then
		for i=1, #moy.level_3_regions[campaign] do
			local region = moy.level_3_regions[campaign][i];			
			core:trigger_event("ScriptEventYvresseDefenceThree");
			moy:apply_mists_of_yvresse_effects(region)
		end
	elseif yvresse_defence >= 75 then
		for i=1, #moy.level_2_regions[campaign] do
			local region = moy.level_2_regions[campaign][i];			
			moy:apply_mists_of_yvresse_effects(region)
		end
	end

end

function moy:purge_mists_of_yvresse()
	local regions_to_purge = moy.level_3_regions[cm:get_campaign_name()]
	out("wh2_dlc15_eltharion_mist: clearing Mists of Yvresse regional effect bundles")
	
	for i=1, #regions_to_purge do
		local region = regions_to_purge[i];
		local game_interface = cm:get_game_interface();
		game_interface:remove_effect_bundle_from_region("wh2_dlc15_hef_mist_of_yvresse_3", region)
		game_interface:remove_effect_bundle_from_region("wh2_dlc15_hef_mist_of_yvresse_2", region)
		game_interface:remove_effect_bundle_from_region("wh2_dlc15_hef_mist_of_yvresse_1", region)
	end
end


----checks relevant conditions (Mists upgrades and active Rites) and applies the appropriate effect bundles
function moy:apply_mists_of_yvresse_effects(region)
	local region_interface = cm:get_region(region);
	local game_interface = cm:get_game_interface();
	if not region_interface:is_null_interface() and not region_interface:owning_faction():is_null_interface() and region_interface:owning_faction():culture() == "wh2_main_hef_high_elves" and (region_interface:owning_faction():name() == "wh2_main_hef_yvresse" or region_interface:owning_faction():allied_with(cm:get_faction("wh2_main_hef_yvresse")) == true) then
		
		cm:create_storm_for_region(region, 1, 1, "hef_mist_storm");

		if wh2_dlc15_athel_tamarha_mist_3 == true then
			game_interface:apply_effect_bundle_to_region("wh2_dlc15_hef_mist_of_yvresse_3", region, 0)
		elseif wh2_dlc15_athel_tamarha_mist_2 == true then
			game_interface:apply_effect_bundle_to_region("wh2_dlc15_hef_mist_of_yvresse_2", region, 0)
		elseif wh2_dlc15_athel_tamarha_mist_1 == true then
			game_interface:apply_effect_bundle_to_region("wh2_dlc15_hef_mist_of_yvresse_1", region, 0)
		elseif wh2_dlc15_athel_tamarha_mist_1 == false then
			game_interface:apply_effect_bundle_to_region("wh2_dlc15_hef_mist_of_yvresse_1", region, 0)
		end

		if cm:get_faction("wh2_main_hef_yvresse"):has_effect_bundle("wh2_dlc15_ritual_hef_ladrielle") then
			game_interface:apply_effect_bundle_to_region("wh2_dlc15_hef_mist_of_yvresse_rite_empowered", region, 0)
		elseif cm:get_region(region):has_effect_bundle("wh2_dlc15_hef_mist_of_yvresse_rite_empowered") then
			game_interface:remove_effect_bundle_from_region("wh2_dlc15_hef_mist_of_yvresse_rite_empowered", region)
		end;

	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("wh2_dlc15_athel_tamarha_mist_1", wh2_dlc15_athel_tamarha_mist_1, context);
		cm:save_named_value("wh2_dlc15_athel_tamarha_mist_2", wh2_dlc15_athel_tamarha_mist_2, context);
		cm:save_named_value("wh2_dlc15_athel_tamarha_mist_3", wh2_dlc15_athel_tamarha_mist_3, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		wh2_dlc15_athel_tamarha_mist_1 = cm:load_named_value("wh2_dlc15_athel_tamarha_mist_1", false, context);
		wh2_dlc15_athel_tamarha_mist_2 = cm:load_named_value("wh2_dlc15_athel_tamarha_mist_2", false, context);
		wh2_dlc15_athel_tamarha_mist_3 = cm:load_named_value("wh2_dlc15_athel_tamarha_mist_3", false, context);
	end
);
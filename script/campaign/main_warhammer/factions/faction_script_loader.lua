

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	FACTION SCRIPT
--
--	First faction-specific file that gets loaded by a scripted campaign. This 
--	works out whether to load the prelude first-turn or not.
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

do
	local cm = get_cm();
	
	--[[
	if core:svr_load_bool("sbool_campaign_includes_prelude_intro") or cm:get_saved_value("bool_prelude_should_load_first_turn") then
		
		-- This value should be set back to false when the first turn of the campaign is completed
		cm:set_saved_value("bool_prelude_should_load_first_turn", true);
		
		cm:set_saved_value("bool_prelude_first_turn_was_loaded", true);
	end;
	]]

	local local_faction = cm:get_local_faction_name(true);

	if local_faction then
		if core:is_tweaker_set("benchmark_campaign_start_script_enabled") then
			cm:load_global_script(local_faction .. "_start_benchmark");
		else
			cm:load_global_script(local_faction .. "_start");
		end;
	end;

end;

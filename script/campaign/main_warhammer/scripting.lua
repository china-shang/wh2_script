

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	CAMPAIGN SCRIPT
--
--	First file that gets loaded by a scripted campaign. This shouldn't need
--	to be changed per-campaign. It loads the campaign script and a required.lua
--	file which lives in the campaign script folder.
--	
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- load lua script libraries
load_script_libraries();

-- change this to false to not load the script
local load_script = true;

if not load_script then
	out("*** WARNING: Not loading script for campaign as load_script variable is set to false! Edit lua file at " .. get_full_file_path() .. " to change this back ***");
	return;
end;

-- name of the campaign, sourced from the name of the containing folder
campaign_name = get_folder_name_and_shortform();

-- set the campaign name on the campaign manager
cm:set_campaign_name(campaign_name);

-- include path to scripts in script/campaign/<campaign_name>/* associated with this campaign
cm:require_path_to_campaign_folder(campaign_name);

-- name of the local faction, to be filled in later
local_faction = "";

-- require a file in the factions subfolder that matches the name of our local faction. The model will be set up by the time
-- the ui is created, so we wait until this event to query who the local faction is. This is why we defer loading of our
-- faction scripts until this time.
cm:add_pre_first_tick_callback(
	function()	
		-- record the name of the local faction
		local_faction = cm:get_local_faction_name(true);
		
		if local_faction then
			-- include path to scripts in script/campaigns/<campaign_name>/factions/<faction_name>/* associated with this campaign/faction
			cm:require_path_to_campaign_faction_folder();
        
			out("Loading faction script for faction " .. local_faction);
			out.inc_tab();
			
			-- faction scripts loaded here
			if cm:load_global_script("faction_script_loader") then
				out.dec_tab();
				out("Faction scripts loaded");
			else
				out.dec_tab();
			end;
		end;
	end
);


-------------------------------------------------------
--	function to call when the first tick occurs
-------------------------------------------------------

cm:add_first_tick_callback(
	function()		
		-- call the start_game_for_faction() function if it exists
		if is_function(start_game_for_faction) then
			start_game_for_faction(true);
		elseif local_faction then
			script_error("start_game_for_faction() function is being called but hasn't been loaded - the script has gone wrong somewhere else, investigate!");
		end;
		
		-- call the start_game_all_factions() function if it exists
		if is_function(start_game_all_factions) then
			start_game_all_factions();
		end;
	end
);

-------------------------------------------------------
--	additional script files to load - customise this
-------------------------------------------------------

require("required");





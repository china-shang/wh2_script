



--
-- 	Scripted behaviour for the frontend
--


--	load script libraries
load_script_libraries();





-- load other frontend files
require("frontend_custom_loading_screens");






-- attempt to generate documentation if we haven't already this game session
do
	local svr = ScriptedValueRegistry:new();
	
	if (core:is_tweaker_set("ALWAYS_GENERATE_SCRIPT_DOCGEN") or svr:LoadPersistentBool("autodoc_generated") ~= true) and vfs.exists("script/docgen.lua") then
		require("script.docgen");
		
		if generate_documentation() then
			svr:SavePersistentBool("autodoc_generated", true);
		end;
	end;
end


--	set the default campaign launch mode to not launch the prelude battle by default
core:svr_save_bool("sbool_player_selected_first_turn_intro_on_frontend", false);


core:add_ui_created_callback(
	function(context)
		start_new_campaign_listener();
		start_campaign_launch_listener();
		output_uicomponent_on_click();
		
		-- go to the credits screen immediately if this saved value is set
		if core:svr_load_bool("sbool_frontend_play_credits_immediately") then
			core:svr_save_bool("sbool_frontend_play_credits_immediately", false);
		
			local uic_button_credits = find_uicomponent("button_credits");
			
			if uic_button_credits then
				uic_button_credits:SimulateLClick();
			end;
		end;
		
		if core:is_tweaker_set("UNLOCK_FRONTEND_MOVIES") then
			unlock_campaign_movies();
		end;
	end
);


--	listen for the singleplayer grand campaign screen being opened and
--	work out if we should check the 'start prelude' checkbox by default
function start_new_campaign_listener()
	core:add_listener(
		"start_new_campaign_listener",
		"FrontendScreenTransition",
		function(context) return context.string == "sp_grand_campaign" end,
		function(context)
			local uic_grand_campaign = find_uicomponent("sp_grand_campaign");
				
			if not uic_grand_campaign then
				script_error("ERROR: start_new_campaign_listener() couldn't find uic_grand_campaign, how can this be?");
				return false;
			end;
				
			if uic_grand_campaign:GetProperty("campaign_key") == "wh2_main_great_vortex" and should_check_start_prelude_by_default() then
				out("Checking prelude checkbox as player has not listened to any startup advice");
				
				uic_grand_campaign:InterfaceFunction("SetupForFirstTime");
			end;
		end,
		true	
	);
end;


--	listen for the 'start campaign' button being clicked and work out if we should
--	start the prelude battle based on the value of the 'start prelude' checkbox
function start_campaign_launch_listener()
	core:add_listener(
		"start_campaign_button_listener",
		"ComponentLClickUp",
		function(context) return context.string == "button_start_campaign" end,
		function(context)			
			-- work out if we have to load the full intro
			local uic_prelude = find_uicomponent("checkbox_start_prelude");
			intro_enabled = (uic_prelude and uic_prelude:CurrentState() == "selected") or core:is_tweaker_set("FORCE_FULL_CAMPAIGN_PRELUDE");
			
			-- try and set a custom loading screen
			set_custom_loading_screen(intro_enabled)
			
			if intro_enabled then
				-- this value will be read by the campaign script to decide what to do
				core:svr_save_bool("sbool_player_selected_first_turn_intro_on_frontend", true);
			end;
		end,
		true
	);
end;







function set_custom_loading_screen(intro_enabled)
	local ui_root = core:get_ui_root();

	-- work out which campaign/lord is selected
	for i = 0, ui_root:ChildCount() - 1 do
		local uic_root_child = UIComponent(ui_root:Find(i));
		
		if uic_root_child:Visible() then
			-- this child of root is visible (it may be a campaign), see if we can find lord select list
			local uic_lord_select_list = find_uicomponent(uic_root_child, "lord_select_list", "list_box");
			
			if uic_lord_select_list then
				-- we have a campaign screen with a visible lord_select_list
				-- go through the lords in the list, and work out which one is selected
				for j = 0, uic_lord_select_list:ChildCount() - 1 do
					local uic_child = UIComponent(uic_lord_select_list:Find(j));
					
					if uic_child:CurrentState() == "selected" then
						local start_pos_id = uic_child:GetProperty("lord_key");
						
						-- the player is starting a campaign with this faction, see if we have a custom loading screen for it
						if intro_enabled then
							local loading_screen = custom_loading_screens_with_intro[start_pos_id];
							if loading_screen then
								out("set_custom_loading_screen() is overriding loading screen with text key [" .. loading_screen .. "], first-turn intro is enabled");
								effect.set_custom_loading_screen_key(loading_screen);
							else
								script_error("ERROR: set_custom_loading_screen() called, but couldn't find a loading screen override for character with start pos id " .. start_pos_id .. " (first-turn intro is enabled)");
							end;
						else
							local loading_screen = custom_loading_screens_no_intro[start_pos_id];
							if loading_screen then
								out("set_custom_loading_screen() is overriding loading screen with text key [" .. loading_screen .. "], starting normal campaign without first-turn intro");
								effect.set_custom_loading_screen_key(loading_screen);
							else
								script_error("ERROR: set_custom_loading_screen() called, but couldn't find a loading screen override for character with start pos id " .. start_pos_id .. " (normal campaign without first-turn intro)");
							end;
						end;
						
						return;
					end;
				end;
				
				script_error("ERROR: set_custom_loading_screen() called but couldn't find a selected lord");
				return;
			end;
		end;
	end;
	
	script_error("ERROR: set_custom_loading_screen() called but couldn't find a visible campaign screen");
end;











--	for each intro advice thread key, check its score - if it's above 0 then it's been played
--	before, so we shouldn't check the start prelude checkbox
function should_check_start_prelude_by_default()
	if _G.is_autotest then
		out("This is an autorun so not checking prelude checkbox");
		return false;
	end;
	
	if core:is_tweaker_set("PRELUDE_BATTLE_DISABLED_BY_DEFAULT") then
		out("Tweaker PRELUDE_BATTLE_DISABLED_BY_DEFAULT is set so not checking prelude checkbox");
		return false;
	end;

	if effect.get_advice_history_string_seen("player_has_stated_campaign") or effect.get_advice_history_string_seen("player_has_started_campaign") then
		return false;
	end;
	
	return true;
end;




function unlock_campaign_movies()
	local movies_to_unlock = {
		"def_horned_rat",
		"def_ritual_1",
		"def_ritual_2",
		"def_ritual_3",
		"def_ritual_4",
		"def_ritual_5",
		"def_win",
		"hef_horned_rat",
		"hef_ritual_1",
		"hef_ritual_2",
		"hef_ritual_3",
		"hef_ritual_4",
		"hef_ritual_5",
		"hef_win",
		"lzd_horned_rat",
		"lzd_ritual_1",
		"lzd_ritual_2",
		"lzd_ritual_3",
		"lzd_ritual_4",
		"lzd_ritual_5",
		"lzd_win",
		"skv_horned_rat",
		"skv_ritual_1",
		"skv_ritual_2",
		"skv_ritual_3",
		"skv_ritual_4",
		"skv_ritual_5",
		"skv_win",
		"skv_comet",
		"battle_arkhan",
		"battle_khalida",
		"battle_khatep",
		"battle_settra",
		"book_1",
		"book_1_arkhan",
		"book_2",
		"book_2_arkhan",
		"book_3",
		"book_3_arkhan",
		"book_4",
		"book_4_arkhan",
		"intro_arkhan",
		"intro_khalida",
		"intro_khatep",
		"intro_settra",
		"win_arkhan",
		"win_khalida",
		"win_khatep",
		"win_settra",
		"cst_battle_aranessa",
		"cst_battle_cylostra",
		"cst_battle_harkon",
		"cst_battle_noctilus",
		"cst_intro_aranessa",
		"cst_intro_cylostra",
		"cst_intro_harkon",
		"cst_intro_noctilus",
		"cst_items",
		"cst_win_aranessa",
		"cst_win_cylostra",
		"cst_win_harkon",
		"cst_win_noctilus",
		"cst_wreck",
		"hunter_wulfhart_win",
		"hunter_wulfhart_call_to_arms",
		"hunter_nakai_win",
		"hunter_nakai_call_to_arms",
		"hunter_intro",
		"shadow_intro",
		"shadow_snikch_call_to_arms",
		"shadow_snikch_win",
		"shadow_malus_call_to_arms",
		"shadow_malus_win",
		"warden_intro",
		"warden_grom_call_to_arms",
		"warden_grom_win",
		"warden_eltharion_call_to_arms",
		"warden_eltharion_win",
		"twilight_intro",
		"twilight_sisters_call_to_arms",
		"twilight_sisters_win",
		"twilight_throt_call_to_arms",
		"twilight_throt_win",
		"silence_intro",
		"oxyotl_call_to_arms",
		"oxyotl_win",
		"taurox_call_to_arms",
		"taurox_win"
	};
	
	for i = 1, #movies_to_unlock do
		core:svr_save_registry_bool(movies_to_unlock[i], true);
	end;
end;
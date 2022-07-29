local repanse_faction = "wh2_dlc14_brt_chevaliers_de_lyonesse";
local knights_flame = "wh2_main_brt_knights_of_the_flame";
local knights_origo = "wh2_main_brt_knights_of_origo";
local knights_flame_fired = false;
local knights_origo_fired = false;
local flame_mission_completed = false;
local origo_mission_completed = false;


function add_repanse_confederation_listeners()
	out("#### Adding Repanse Confederation Listerners ####");
	local repanse_interface = cm:model():world():faction_by_key(repanse_faction); 
	--check if Repanse is human
	if repanse_interface:is_null_interface() == false and repanse_interface:is_human() == true then			
		core:add_listener(
			"repanse_trigger_dilemma",
			"MissionSucceeded",
			function(context)
				local mission = context:mission():mission_record_key();
				return mission == "wh2_dlc14_brt_repanse_early_game_eliminate_faction" or mission == "wh2_dlc14_vor_brt_repanse_capture_arkhan" or mission == "wh2_dlc14_brt_repanse_capture_arkhan" or mission == "wh2_dlc14_repanse_mission_own_province"
			end,
			function(context)
				local mission = context:mission():mission_record_key();
				if mission == "wh2_dlc14_brt_repanse_early_game_eliminate_faction" or mission == "wh2_dlc14_repanse_mission_own_province" then 
					local origo_interface = cm:model():world():faction_by_key(knights_origo); 
					origo_mission_completed = true;
					if origo_interface:is_null_interface() == false and origo_interface:is_dead() == false then
						cm:trigger_dilemma(repanse_faction, "wh2_dlc14_brt_confederation_knights_of_origo");
					end	
				elseif mission == "wh2_dlc14_vor_brt_repanse_capture_arkhan" or mission == "wh2_dlc14_brt_repanse_capture_arkhan" then
					local flame_interface = cm:model():world():faction_by_key(knights_flame); 
					flame_mission_completed = true;
					if flame_interface:is_null_interface() == false and flame_interface:is_dead() == false then				
						cm:trigger_dilemma(repanse_faction, "wh2_dlc14_brt_confederation_knights_of_the_flame");
					end
				end
			end,
			true
		);
		core:add_listener(
			"repanse_trigger_dilemma",
			"DilemmaChoiceMadeEvent",
			function(context)
				local dilemma = context:dilemma();
				return dilemma == "wh2_dlc14_brt_confederation_knights_of_origo" or dilemma == "wh2_dlc14_brt_confederation_knights_of_the_flame";
			end,
			function(context)
				local dilemma = context:dilemma();
				local choice = context:choice();
				if dilemma == "wh2_dlc14_brt_confederation_knights_of_origo" then 
					if choice == 0 then
						cm:force_confederation(repanse_faction, knights_origo);
						knights_origo_fired = true;
						out(knights_origo_fired);
					elseif choice == 1 then
						knights_origo_fired = true;
						out(knights_origo_fired);
					end
				elseif dilemma == "wh2_dlc14_brt_confederation_knights_of_the_flame" then 						
					if choice == 0 then					
						cm:force_confederation(repanse_faction, knights_flame);
						knights_flame_fired = true;
					elseif choice == 1 then
						knights_flame_fired = true;
						out(knights_flame_fired);	
					end
				end
			end,
			true
		);
	end
	if knights_origo_fired == false and origo_mission_completed == true then
		cm:trigger_dilemma(repanse_faction, "wh2_dlc14_brt_confederation_knights_of_origo");
	end
	if knights_flame_fired == false and flame_mission_completed == true then
		cm:trigger_dilemma(repanse_faction, "wh2_dlc14_brt_confederation_knights_of_the_flame");
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("knights_flame_fired", knights_flame_fired, context);
		cm:save_named_value("knights_origo_fired", knights_origo_fired, context);
		cm:save_named_value("flame_mission_completed", flame_mission_completed, context);
		cm:save_named_value("origo_mission_completed", origo_mission_completed, context);
	end
);
cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			knights_flame_fired = cm:load_named_value("knights_flame_fired", knights_flame_fired, context);
			knights_origo_fired = cm:load_named_value("knights_origo_fired", knights_origo_fired, context);
			flame_mission_completed = cm:load_named_value("flame_mission_completed", flame_mission_completed, context);
			origo_mission_completed = cm:load_named_value("origo_mission_completed", origo_mission_completed, context);
		end
	end
);
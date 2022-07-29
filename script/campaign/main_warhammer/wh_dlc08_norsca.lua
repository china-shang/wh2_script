NORSCA_SUBCULTURE = "wh_main_sc_nor_norsca";
NORSCA_CONFEDERATION_DILEMMA = "wh2_dlc08_confederate_";
NORSCA_CONFEDERATION_PLAYER = "";
NORSCA_ADVICE = {};

function Add_Norsca_Listeners()
	out("#### Adding Norsca Listeners ####");
	core:add_listener(
		"Norsca_CharacterEntersGarrison",
		"CharacterEntersGarrison",
		true,
		function(context) Norsca_CharacterEntersGarrison(context) end,
		true
	);
	core:add_listener(
		"Norsca_Settlement_Captured",
		"PanelOpenedCampaign",
		true,
		function(context) Norsca_Settlement_Captured(context) end,
		true
	);
	core:add_listener(
		"Norsca_Confed_DilemmaChoiceMadeEvent",
		"DilemmaChoiceMadeEvent",
		function(context)
			return context:dilemma():starts_with(NORSCA_CONFEDERATION_DILEMMA);
		end,
		function(context)
			Norsca_Confederation_Choice(context);
		end,
		true
	);
end

function Norsca_Settlement_Captured(context)
	if context.string == "settlement_captured" then
		local turn_faction = cm:model():world():whose_turn_is_it();
		
		if turn_faction:is_null_interface() == false and turn_faction:is_human() == true and turn_faction:subculture() == NORSCA_SUBCULTURE then
			Play_Norsca_Advice("dlc08.camp.advice.nor.gods.001", norsca_info_text_gods);
		end
	end
end


core:add_listener(
	"character_completed_battle_norsca_confederation_dilemma",
	"CharacterCompletedBattle",
	true,
	function(context)
		local character = context:character();
		
		if character:won_battle() == true and character:faction():subculture() == NORSCA_SUBCULTURE then
			local enemies = cm:pending_battle_cache_get_enemies_of_char(character);
			local enemy_count = #enemies;
			
			if context:pending_battle():night_battle() == true or context:pending_battle():ambush_battle() == true then
				enemy_count = 1;
			end

			local character_cqi = character:command_queue_index();
			local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(1);
			local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(1);
			
			if character_cqi == attacker_cqi or character_cqi == defender_cqi then
				for i = 1, enemy_count do
					local enemy = enemies[i];
					
					if enemy ~= nil and enemy:is_null_interface() == false and enemy:is_faction_leader() == true and enemy:faction():subculture() == NORSCA_SUBCULTURE then
						if enemy:has_military_force() == true and enemy:military_force():is_armed_citizenry() == false then
							if character:faction():is_human() == true and enemy:faction():is_human() == false and enemy:faction():is_dead() == false then
								-- Trigger dilemma to offer confederation
								NORSCA_CONFEDERATION_PLAYER = character:faction():name();
								cm:trigger_dilemma(NORSCA_CONFEDERATION_PLAYER, NORSCA_CONFEDERATION_DILEMMA..enemy:faction():name());
								Play_Norsca_Advice("dlc08.camp.advice.nor.confederation.001", norsca_info_text_confederation);
							elseif character:faction():is_human() == false and enemy:faction():is_human() == false then
								-- AI confederation
								cm:force_confederation(character:faction():name(), enemy:faction():name());
							end
						end
					end
				end
			end
		end
	end,
	true
);


function Norsca_Confederation_Choice(context)
	local faction = string.gsub(context:dilemma(), NORSCA_CONFEDERATION_DILEMMA, "");
	local choice = context:choice();
	
	if choice == 0 then
		-- Confederate
		cm:force_confederation(NORSCA_CONFEDERATION_PLAYER, faction);
	elseif choice == 1 then
		-- Kill leader
		local enemy = cm:model():world():faction_by_key(faction);
		
		if enemy:has_faction_leader() == true then
			local leader = enemy:faction_leader();
			
			if leader:character_subtype("wh_dlc08_nor_wulfrik") == false and leader:character_subtype("wh_dlc08_nor_throgg") == false then
				local cqi = leader:command_queue_index();
				cm:set_character_immortality("character_cqi:"..cqi, false);
				cm:kill_character(cqi, false, true);
			end
		end
	end
	
	-- autosave on legendary
	if cm:model():difficulty_level() == -3 and not cm:is_multiplayer() then
		cm:callback(function() cm:autosave_at_next_opportunity() end, 0.5);
	end;
end

function Norsca_CharacterEntersGarrison(context)
	local character = context:character();
	
	if character:has_region() == true and character:faction():subculture() == NORSCA_SUBCULTURE then
		local region = character:region();
		local region_name = region:name();
		
		if region_name == "wh_main_tilea_miragliano" then
			Play_Norsca_Advice("dlc08.camp.advice.nor.outposts_miragliano.001", norsca_info_text_outposts);
		elseif region_name == "wh_main_reikland_altdorf" then
			Play_Norsca_Advice("dlc08.camp.advice.nor.outposts_altdorf.001", norsca_info_text_outposts);
		elseif region_name == "wh_main_eastern_sylvania_castle_drakenhof" then
			Play_Norsca_Advice("dlc08.camp.advice.nor.outposts_drakenhof.001", norsca_info_text_outposts);
		elseif region_name == "wh_main_couronne_et_languille_couronne" then
			Play_Norsca_Advice("dlc08.camp.advice.nor.outposts_couronne.001", norsca_info_text_outposts);
		elseif region_name == "wh_main_death_pass_karak_drazh" then
			Play_Norsca_Advice("dlc08.camp.advice.nor.outposts_black_crag.001", norsca_info_text_outposts);
		elseif region_name == "wh_main_the_silver_road_karaz_a_karak" then
			Play_Norsca_Advice("dlc08.camp.advice.nor.outposts_karaz_a_karak.001", norsca_info_text_outposts);
		end
		
		cm:callback(function()
			if NORSCA_ADVICE["dlc08.camp.advice.nor.outposts.001"] ~= true then -- Early Check
				if region:building_exists("wh_main_nor_outpost_major_dwarfhold_1_coast") or region:building_exists("wh_main_nor_outpost_major_human_1_coast") or region:building_exists("wh_main_nor_outpost_minor_dwarfhold_1_coast") or region:building_exists("wh_main_nor_outpost_minor_human_1_coast") or
				region:building_exists("wh_main_nor_outpost_major_dwarfhold_2_coast") or region:building_exists("wh_main_nor_outpost_major_human_2_coast") or region:building_exists("wh_main_nor_outpost_minor_dwarfhold_2_coast") or region:building_exists("wh_main_nor_outpost_minor_human_2_coast") or
				region:building_exists("wh_main_nor_outpost_major_dwarfhold_3_coast") or region:building_exists("wh_main_nor_outpost_major_human_3_coast") or region:building_exists("wh_main_nor_outpost_minor_dwarfhold_3_coast") or region:building_exists("wh_main_nor_outpost_minor_human_3_coast") then
					Play_Norsca_Advice("dlc08.camp.advice.nor.outposts.001", norsca_info_text_outposts);
				end
			end
		end, 0.5);
	end
end

norsca_info_text_gods = {"war.camp.prelude.nor.gods.info_001", "war.camp.prelude.nor.gods.info_002", "war.camp.prelude.nor.gods.info_003"};
norsca_info_text_confederation = {"war.camp.prelude.nor.confederation.info_001", "war.camp.prelude.nor.confederation.info_002", "war.camp.prelude.nor.confederation.info_003"};
norsca_info_text_outposts = {"war.camp.prelude.nor.outposts.info_001", "war.camp.prelude.nor.outposts.info_002", "war.camp.prelude.nor.outposts.info_003"};
norsca_info_text_monsters = {"war.camp.prelude.nor.monsters.info_001", "war.camp.prelude.nor.monsters.info_002", "war.camp.prelude.nor.monsters.info_003"};

function Play_Norsca_Advice(advice, infotext)
	if cm:model():is_multiplayer() == false then
		if effect.get_advice_level() >= 1 then
			local turn_faction = cm:model():world():whose_turn_is_it();
			
			if turn_faction:is_null_interface() == false and turn_faction:is_human() == true and turn_faction:subculture() == NORSCA_SUBCULTURE then
				if NORSCA_ADVICE[advice] ~= true then
					NORSCA_ADVICE[advice] = true;
					cm:clear_infotext();
					cm:show_advice(advice, true);
					
					if infotext ~= nil then
						cm:add_infotext(1, unpack(infotext));
					end
				end
			end
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("NORSCA_ADVICE", NORSCA_ADVICE, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		NORSCA_ADVICE = cm:load_named_value("NORSCA_ADVICE", {}, context);
	end
);
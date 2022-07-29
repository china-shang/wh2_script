


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	OPEN CAMPAIGN INTRO SCRIPT
--
--	Script for the intro to the main open campaign - loaded if the player hasn't
--	selected to play the intro first turn on the frontend, or if they have and
--	they've completed it
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

---------------------------------------------------------------
--	Start the open campaign from the intro cutscene (first-turn skipped)
---------------------------------------------------------------

function start_open_campaign_from_intro_cutscene()

	-- show advisor dismiss button
	cm:modify_advice(true);

	start_open_campaign(false);
end;










---------------------------------------------------------------
--	Start the open campaign (shared)
---------------------------------------------------------------

function start_open_campaign(from_intro_first_turn)
	out("start_open_campaign() called, from intro first turn: " .. tostring(from_intro_first_turn));
	
	-- start interventions
	start_interventions();
	
	-- kicks off mission proceedings
	start_early_game_missions(from_intro_first_turn, true);
end;








---------------------------------------------------------------
--	Start all faction-specific interventions
---------------------------------------------------------------

function start_interventions()

	out.interventions("* start_interventions() called");
	out("* start_interventions() called");
	
	-- global
	start_global_interventions(true);
end;


















---------------------------------------------------------------
--	Early-game missions
--	Start the listeners that trigger the early-game missions.
--	the underlying functions are found in wh2_early_game.lua
---------------------------------------------------------------

-- do this immediately upon load of this file
do
	local enemy_faction_str = "wh_main_grn_top_knotz";
	local ally_faction_str = "wh2_dlc09_tmb_numas";

	-- how they play event message that appears at the start of the open campaign
	start_early_game_how_they_play_listener();
	
	local difficulty_level = cm:model():difficulty_level();
	
	do
		local personality_key = "wh2_greenskin_noruins_survivor_aggressive";
		
		if difficulty_level == 0 or difficulty_level == -1 then
			personality_key = "wh2_greenskin_noruins_survivor_aggressive";				-- normal/hard
		elseif difficulty_level == -2 or difficulty_level == -3 then
			personality_key = "wh2_greenskin_noruins_survivor_aggressive_hard";			-- v.hard/legendary
		end;
		
		-- prevents the supplied principal enemy faction from being able to request peace, sets them into the supplied personality, and prevents anyone from arranging a NAP or a trade agreement with the player until a message is received
		-- also prevents anyone declaring war with the player for the specified number of turns from the start of the game
		-- enemy_faction_key, enemy_personality_key, num_turns_before_war
		start_early_game_diplomacy_setup_listener(
			enemy_faction_str,
			personality_key,
			3
		);
	end;
	
	
	-- diplomatically restricts those rogue factions that hold Books of Nagash to just being
	-- able to receive declarations of war from the player
	start_early_game_books_of_nagash_holder_diplomacy_listener(tomb_kings_books_of_nagash_holder_rogue_faction_list);
	
	
	-- set the first turn count modifier - this tells early-game scripts that the first-turn turn should not be counted towards missions that trigger on certain turns
	if not cm:get_saved_value("first_turn_count_modifier") then
		cm:set_saved_value("first_turn_count_modifier", 0);
	end;
	
	
	-- books of nagash mission
	-- issued after the how-they-play event is dismissed
	-- mission_key, mission_issuer, mission_rewards
	start_early_game_books_of_nagash_mission_listener(
		"wh2_dlc09_books_of_nagash", 
		"PRIEST_NERUTEP",
		{
			"money 3000",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_acquire_book_of_nagash_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- capture enemy settlement mission that triggers on the first turn of the open campaign
	-- advice_key, infotext (nil for default), mission_key, enemy_region_name, enemy_faction_name, mission_rewards
	start_early_game_capture_enemy_settlement_mission_listener(
		-- Green-skinned vermin! They shall be first to feel my wrath - I shall burn their hovels and flay their worthless husks as an example to all that would trespass upon my realm!
		"dlc09.camp.vortex.settra.early_game.001",
		nil, 
		"dlc09_main_tmb_settra_early_game_capture_settlement",
		"PRIEST_NERUTEP",
		"wh2_main_vor_land_of_the_dead_the_salt_plain",
		enemy_faction_str,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_capture_enemy_settlement_mission_canopic_jars_payload_amount .. ";}"
		},
		false,
		true
	);
	
	
	-- capture province listener - triggers on completion of the capture enemy settlement mission (see above), or when the player 
	-- captures a settlement not in their starting province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_capture_province_mission_listener(
		-- Your occupation forces gain you control over new lands, my Lord. Further conquest in this province will grant you complete dominion over those that live there.
		"wh2.camp.vortex.advice.early_game.provinces.001",
		nil,
		"dlc09_main_tmb_settra_early_game_capture_province",
		"PRIEST_NERUTEP",
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_capture_province_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- enact commandment listener - triggers when the player captures a province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_enact_commandment_mission_listener(
		-- Your armed forces have secured the province, my Lord. Any contesting claim to this territory has been eliminated. Now that your rule is unquestioned, you may consider issuing a commandment to rouse the populace, so that they may better serve your ends.
		"wh2.camp.vortex.advice.early_game.commandments.001",
		nil,
		"dlc09_main_tmb_settra_early_game_enact_commandment",
		"PRIEST_NERUTEP",
		{
			"money 500"
		}
	);
	
	
	-- search ruins listener
	-- triggers at the start of the supplied turn
	-- advice_key, infotext, region_key, trigger_turn, mission_key, mission_issuer, mission_rewards, factions_personalities_mapping
	start_early_game_search_ruins_mission_listener(		
		-- The remnants of long-abandoned cities may yet yield uncovered treasure. Send armed forces to search those ruins you may find, my Lord, and great riches may be yours.
		"wh2.camp.vortex.advice.early_game.treasure_hunting.001",
		nil,
		"wh2_main_vor_land_of_the_dead_zandri",
		9,
		"dlc09_main_tmb_settra_early_game_search_ruins",
		"PRIEST_NERUTEP",
		{
			"money 500",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_search_ruins_mission_canopic_jars_payload_amount .. ";}"
		},
		{		-- factions to modify the personality of
			{
				["faction_key"] = "wh2_main_brt_knights_of_origo",
				["start_personality_easy"] = "wh2_passive_noruins_easy",
				["start_personality_normal"] = "wh2_passive_noruins",
				["start_personality_hard"] = "wh2_passive_noruins_hard",
				["complete_personality_easy"] = "wh_teb_default_easy",
				["complete_personality_normal"] = "wh_teb_default",
				["complete_personality_hard"] = "wh_teb_default_hard"
			},
			{
				["faction_key"] = "wh2_dlc09_tmb_rakaph_dynasty",
				["start_personality_easy"] = "wh2_passive_noruins_easy",
				["start_personality_normal"] = "wh2_passive_noruins",
				["start_personality_hard"] = "wh2_passive_noruins_hard",
				["complete_personality_easy"] = "wh_vampires_early_default_easy",
				["complete_personality_normal"] = "wh_vampires_early_default",
				["complete_personality_hard"] = "wh_vampires_early_default_hard"
			}
		}
	);
	
	
	-- rogue armies listener
	-- spawns a rogue army the turn after the player searches ruins
	-- advice_key, infotext, mission_key, rogue_army_faction_name, rogue_army_position_list, rogue_army_unit_list, rogue_army_home_region, mission_rewards
	start_early_game_rogue_army_mission_listener(
		-- A wandering host approaches! Beware of such 'rogue armies', my Lord - they must not be allowed to threaten your realm. Do not tolerate their incursions on your soil!
		"wh2.camp.vortex.advice.early_game.rogue_armies.001", 
		nil,
		"dlc09_main_tmb_settra_early_game_rogue_armies",
		"PRIEST_NERUTEP",
		"wh2_main_rogue_vauls_expedition",
		{
			{v(622, 321), "wh2_main_vor_land_of_the_dead_zandri"},
			{v(582, 328), "wh2_main_vor_coast_of_araby_al_haikk"},
			{v(561, 290), "wh2_main_vor_the_great_desert_pools_of_despair"}
		},
		"wh2_main_hef_inf_archers_1,wh2_main_hef_inf_archers_1,wh2_main_hef_inf_swordmasters_of_hoeth_0,wh2_main_hef_inf_spearmen_0,wh2_main_hef_inf_spearmen_0,wh2_main_hef_cha_mage_life_0",
		"wh2_main_vor_coast_of_araby_fyrus",
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_rogue_army_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- research tech mission
	-- triggers once the player has built a tech-capable building
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_research_tech_mission_listener(
		-- The Dynasties of the Tomb Kings are venerated throughout the ages. Great power may be attained through alignment with your ancestors, my Lord.
		"dlc09.camp.vortex.advice.early_game.dynasties.001",
		{
			1,
			"war.camp.advice.dynasties.info_001",			-- create default infotext
			"war.camp.advice.dynasties.info_002",
			"war.camp.advice.dynasties.info_003"
		},
		"dlc09_main_tmb_settra_early_game_research_dynasty",
		"PRIEST_NERUTEP",
		{
			"money 1000"
		},
		true												-- trigger after capture-settlement mission is issued
	);
	
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		-- The enemy recoils before your legions, Great King. End these pests once and for all.
		"dlc09.camp.vortex.advice.early_game.eliminate_faction.005",
		nil,
		"dlc09_main_tmb_settra_early_game_eliminate_faction",
		"PRIEST_NERUTEP",
		enemy_faction_str,
		1,
		25,
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_eliminate_faction_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- growth point mission
	-- this is a mission for the player to upgrade their settlement (again)
	-- this triggers once the player receives their first growth point in a region with the supplied building, informs the player about growth points, and tasks them to upgrade their settlement further
	-- advice_key, infotext, mission_key, region_key, required_building_key, upgrade_building_key, mission_rewards
	start_early_game_growth_point_mission_listener(
		-- The population of your province grows, mighty Lord. See that the expansion continues, so that you may further develop your realm.
		"wh2.camp.vortex.advice.early_game.growth.001",
		nil,
		"dlc09_main_tmb_settra_early_game_upgrade_settlement_part_two",
		"PRIEST_NERUTEP",
		khemri_region_str,
		{
			"wh2_dlc09_special_settlement_khemri_tmb_2",
			"wh2_dlc09_tmb_settlement_major_2",
			"wh2_dlc09_tmb_settlement_major_coast_2"
		},
		{
			"wh2_dlc09_special_settlement_khemri_tmb_3",
			"wh2_dlc09_tmb_settlement_major_3",
			"wh2_dlc09_tmb_settlement_major_coast_3",
			"wh2_dlc09_tmb_settlement_minor_3",
			"wh2_dlc09_tmb_settlement_minor_coast_3"
		},
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_growth_point_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- hero technology mission
	-- triggers once the player completes the research technology mission
	-- advice_key, infotext, mission_key, mission_issuer, mission_rewards
	start_early_game_hero_technology_mission_listener(
		-- Heroes of the ancient Dynasties may be awakened if you desire it, my Lord. Once resurrected, such warriors may be of assistance to your cause.
		"dlc09.camp.vortex.advice.early_game.tomb_kings_hero_technologies.001",
		nil, 
		"dlc09_main_tmb_settra_early_game_hero_technology_mission", 
		"PRIEST_NERUTEP", 
		{
			"money 500",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_growth_point_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- hero recruitment mission
	-- triggers if the player completes the hero technology mission
	-- issues the supplied advice, and a mission to recruit a hero
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_hero_recruitment_mission_listener(
		-- Facilities are now in place to recruit a Hero, my Lord. Such operatives may move behind enemy lines and strike independently of your armies.
		"wh2.camp.vortex.advice.early_game.recruit_hero.001",
		nil,
		"dlc09_main_tmb_settra_early_game_hero_recruitment_mission",
		"PRIEST_NERUTEP",
		{
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_hero_recruitment_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- hero action mission
	-- triggers when the player gains their first hero
	-- issues the supplied advice, and a mission to use a hero action
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_hero_action_mission_listener(
		-- A hero has enrolled in your service, my Lord. Be sure to put them to work - their unique skills may solve problems that no amount of money or effort would otherwise be able to crack.
		"wh2.camp.vortex.advice.early_game.hero_actions.001",
		nil,
		"dlc09_main_tmb_settra_early_game_hero_action_mission",
		"PRIEST_NERUTEP",
		{
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_hero_action_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- raise army mission
	-- triggers when the player is at war with two armies, is outnumbered and can afford a second army
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_raise_army_mission_listener(
		-- Your war efforts would be strengthened by the raising of a new army. Appoint another command, and you can open a second front against your foes.
		"war.camp.advice.raise_forces.001",
		nil,
		"dlc09_main_tmb_settra_early_game_raise_army_mission",
		"PRIEST_NERUTEP",
		{
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_raise_army_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		-- You need not fight your enemies alone, my Lord, for there are foreign powers sympathetic to your cause. Relations may be built with them through diplomacy. Agreeing a pact of non-aggression with a foreign leader will do much to build trust between you. Trade relations or a military alliance may follow.
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.001",
		nil,
		"dlc09_main_tmb_settra_early_game_non_aggression_pact",
		"PRIEST_NERUTEP",
		ally_faction_str, 
		10,
		{
			"money 500",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_non_aggression_pact_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- trade-agreement mission
	-- triggers after the non-aggression pact mission is completed, when the standing between the player and the target faction has risen sufficiently to make a trade agreement plausible
	-- supplied min_turn_threshold specifies the minimum number of turns after the non-aggression pact is agreed before this can trigger. max_turn_threshold is the maximum number of turns after the nap is agreed
	-- advice_key, infotext, mission_key, target_faction_key, min_turn_threshold, max_turn_threshold, mission_rewards
	start_early_game_trade_agreement_mission_listener(
		-- Relations with the rulers of this place have blossomed since agreeing a pact of non-aggression, my Lord. A trade agreement may now be possible. Let your merchants flourish, for industry creates war.
		"wh2.camp.vortex.advice.early_game.trade_agreements.001",
		nil,
		"dlc09_main_tmb_settra_early_game_trade_agreement",
		"PRIEST_NERUTEP",
		ally_faction_str,
		3,
		12,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_trade_agreement_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- resources mission
	-- Triggers after a supplied number of turns, or if the player goes within a turn's march of the supplied settlement with any military force. It won't trigger if the
	-- player somehow gets the resource beforehand (unless they lose it again).	
	-- advice_key, infotext, region_key, turn_threshold, mission_key, resource_key, mission_issuer, mission_rewards
	start_early_game_resources_mission_listener(
		-- The land yields great riches for those that know where to look. Secure access to resources found further afield, for they may be of use to the Liche Priests of your Mortuary Cult.
		"dlc09.camp.vortex.advice.early_game.resources.001", 
		nil, 
		"wh2_main_vor_southern_badlands_gor_gazan",
		3, 
		"dlc09_main_tmb_settra_early_game_resources", 
		"res_rom_iron", 
		"PRIEST_NERUTEP", 
		{
			"money 500",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_resources_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	
	-- pooled resources mission
	-- Triggers once the player has accumulated the supplied minimum amount of the supplied pooled resource. Issues a mission
	-- to earn the higher threshold of the same resource
	-- advice_key, infotext, mission_key, resource_name, resource_min_threshold, resource_mission_threshold, mission_issuer, mission_rewards
	start_early_game_pooled_resource_mission_listener(
		-- It is within Canopic Jars that the remains of the dead are preserved, and to which their souls are eternally bound. Seek out more such artefacts, for the essences they provide can be prove useful.
		"dlc09.camp.vortex.advice.early_game.canopic_jars.001",
		{
			"war.camp.advice.canopic_jars.info_001",
			"war.camp.advice.canopic_jars.info_002",
			"war.camp.advice.canopic_jars.info_003"
		},
		"dlc09_main_tmb_settra_early_game_canopic_jars",
		"tmb_canopic_jars",
		early_game_canopic_jars_mission_trigger_threshold,
		early_game_canopic_jars_mission_target_threshold,
		"PRIEST_NERUTEP",
		{
			"money 3000"
		}
	);
	
	
	-- mortuary cult mission
	-- Triggers once the player can craft an item in the Mortuary Cult	
	-- advice_key, infotext, mission_key, mission_issuer, mission_rewards
	start_early_game_mortuary_cult_mission_listener(
		-- The artisans of the Mortuary Cult stand ready to assist your cause, my Lord. Employ them to craft powerful artefacts that may aid you in your conquests.
		"dlc09.camp.vortex.advice.early_game.mortuary_cult.001", 
		nil, 
		"dlc09_main_tmb_settra_early_game_mortuary_cult", 
		"PRIEST_NERUTEP", 
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_mortuary_cult_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	-- Tomb Kings recruitment building mission
	-- Triggers at the start of the supplied turn, gives the player a mission to build a building that will allow more units to be recruited
	-- advice_key, infotext, mission_key, trigger_turn, building_list, mission_issuer, mission_rewards
	start_early_game_tmb_recruitment_building_mission_listener(
		-- The monuments you build grant shall you the powers to sustain your armies. Construct more facilities in the cities under your dominion to diversify the forces you command.
		"dlc09.camp.vortex.advice.early_game.tomb_kings_recruitment.001", 
		nil, 
		"dlc09_main_tmb_settra_early_game_recruitment_building",
		2,
		{
			"wh2_dlc09_tmb_chariots_1",
			"wh2_dlc09_tmb_chariots_2",
			"wh2_dlc09_tmb_chariots_3",
			"wh2_dlc09_tmb_infantry_1",
			"wh2_dlc09_tmb_infantry_2",
			"wh2_dlc09_tmb_infantry_3",
			"wh2_dlc09_tmb_cavalry_1",
			"wh2_dlc09_tmb_cavalry_2",
			"wh2_dlc09_tmb_cavalry_3",
			"wh2_dlc09_tmb_cavalry_4",
			-- "wh2_dlc09_tmb_arkhan_burial_mound",
			"wh2_dlc09_tmb_ushabti_1",
			"wh2_dlc09_tmb_ushabti_2",
			"wh2_dlc09_tmb_scorpions_1",
			"wh2_dlc09_tmb_warsphinx_1",
			"wh2_dlc09_tmb_necrosphinx_1",
			"wh2_dlc09_tmb_hierotitan_1",
			"wh2_dlc09_tmb_public_order_2"
		},
		"PRIEST_NERUTEP", 
		{
			"money 500",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_tomb_kings_recruitment_building_mission_canopic_jars_payload_amount .. ";}"
		}
	);
	
	
	
	-- Tomb Kings recruitment building scripted guide and follow-up mission
	-- Triggers once the recruitment building mission is completed. Shows a short scripted tour if the advice hasn't been heard before, otherwise it just issues
	-- a follow-up mission to recruit lots of capless units
	-- advice_key, infotext, mission_key, num of units to recruit, mission_issuer, mission_rewards
	start_early_game_tmb_recruitment_building_guide_listener(
		-- Excellent! See for yourself how more diverse troop-types are now open to recruitment.
		"dlc09.camp.vortex.advice.early_game.tomb_kings_recruitment.002",
		nil,
		"dlc09_main_tmb_settra_early_game_recruit_capless_units",
		8,
		"PRIEST_NERUTEP", 
		{
			"money 500",
			"faction_pooled_resource_transaction{resource tmb_canopic_jars;factor wh2_main_resource_factor_missions;amount " .. early_game_tomb_kings_recruitment_capless_units_canopic_jars_payload_amount .. ";}"
		}
	);
end;


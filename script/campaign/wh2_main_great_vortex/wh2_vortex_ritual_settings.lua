
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	VORTEX RITUAL SETTINGS
--	This script manages the strength of spawned incursions
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- size of incursions, min and max values (experience is randomly selected from the list)
vortex_settings = {
	["easy"] = {
		["ritual_1"] = {
			["num_armies"]				= {{1, 2}, nil, nil}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{1, 2}, nil, nil},
			
			["army_size"]				= {10, 15},
			["character_experience"]	= {6890, 8370, 9940}, -- rank 7, 8, 9
			["unit_rank"]				= 0
		},
		
		["ritual_2"] = {
			["num_armies"]				= {{1, 3}, {1, 2}, nil}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{1, 2}, {1, 2}, nil},
			
			["army_size"]				= {10, 15},
			["character_experience"]	= {15160, 17060, 19040}, -- rank 12, 13, 14
			["unit_rank"]				= 0
		},
		
		["ritual_3"] = {
			["num_armies"]				= {{1, 2}, {1, 2}, {1, 2}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 2}, {1, 2}, nil},
			
			["army_size"]				= {15, 19},
			["character_experience"]	= {25400, 27660, 29980}, -- rank 17, 18, 19
			["unit_rank"]				= 0
		},
		
		["ritual_4"] = {
			["num_armies"]				= {{2, 4}, nil, {1, 3}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 2}, {1, 2}, nil},
			
			["army_size"]				= {15, 19},
			["character_experience"]	= {37300, 39850, 42450}, -- rank 22, 23, 24
			["unit_rank"]				= 0
		},
		
		["ritual_5"] = {
			["num_armies"]				= {nil, nil, {4, 6}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 3}, {2, 2}, nil},
			
			["army_size"]				= {19, 19},
			["character_experience"]	= {53320, 56140, 59000}, -- rank 28, 29, 30
			["unit_rank"]				= 0
		}
	},
	
	["normal"] = {
		["ritual_1"] = {
			["num_armies"]				= {{1, 2}, nil, nil}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{1, 2}, nil, nil},
			
			["army_size"]				= {10, 15},
			["character_experience"]	= {6890, 8370, 9940}, -- rank 7, 8, 9
			["unit_rank"]				= 1
		},
		
		["ritual_2"] = {
			["num_armies"]				= {{1, 3}, {1, 2}, nil}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{1, 2}, {1, 2}, nil},
			
			["army_size"]				= {10, 15},
			["character_experience"]	= {15160, 17060, 19040}, -- rank 12, 13, 14
			["unit_rank"]				= 1
		},
		
		["ritual_3"] = {
			["num_armies"]				= {{1, 2}, {1, 2}, {1, 2}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 2}, {1, 2}, nil},
			
			["army_size"]				= {15, 19},
			["character_experience"]	= {25400, 27660, 29980}, -- rank 17, 18, 19
			["unit_rank"]				= 3
		},
		
		["ritual_4"] = {
			["num_armies"]				= {{2, 4}, nil, {1, 3}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 2}, {1, 2}, nil},
			
			["army_size"]				= {15, 19},
			["character_experience"]	= {37300, 39850, 42450}, -- rank 22, 23, 24
			["unit_rank"]				= 3
		},
		
		["ritual_5"] = {
			["num_armies"]				= {nil, nil, {4, 6}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 3}, {2, 2}, nil},
			
			["army_size"]				= {19, 19},
			["character_experience"]	= {53320, 56140, 59000}, -- rank 28, 29, 30
			["unit_rank"]				= 5
		}
	},
	
	["hard"] = {
		["ritual_1"] = {
			["num_armies"]				= {{2, 3}, nil, nil}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{1, 2}, nil, nil},
			
			["army_size"]				= {10, 15},
			["character_experience"]	= {6890, 8370, 9940}, -- rank 7, 8, 9
			["unit_rank"]				= 2
		},
		
		["ritual_2"] = {
			["num_armies"]				= {{2, 3}, {1, 2}, nil}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{1, 2}, {1, 2}, nil},
			
			["army_size"]				= {10, 15},
			["character_experience"]	= {15160, 17060, 19040}, -- rank 12, 13, 14
			["unit_rank"]				= 3
		},
		
		["ritual_3"] = {
			["num_armies"]				= {{2, 2}, {1, 2}, {1, 2}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 2}, {1, 2}, nil},
			
			["army_size"]				= {15, 19},
			["character_experience"]	= {25400, 27660, 29980}, -- rank 17, 18, 19
			["unit_rank"]				= 5
		},
		
		["ritual_4"] = {
			["num_armies"]				= {{2, 4}, nil, {2, 3}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 2}, {1, 2}, nil},
			
			["army_size"]				= {15, 19},
			["character_experience"]	= {37300, 39850, 42450}, -- rank 22, 23, 24
			["unit_rank"]				= 5
		},
		
		["ritual_5"] = {
			["num_armies"]				= {nil, nil, {5, 7}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 3}, {2, 2}, nil},
			
			["army_size"]				= {19, 19},
			["character_experience"]	= {53320, 56140, 59000}, -- rank 28, 29, 30
			["unit_rank"]				= 7
		}
	},
	
	["very_hard"] = {
		["ritual_1"] = {
			["num_armies"]				= {{2, 3}, nil, nil}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{1, 2}, nil, nil},
			
			["army_size"]				= {10, 15},
			["character_experience"]	= {6890, 8370, 9940}, -- rank 7, 8, 9
			["unit_rank"]				= 2
		},
		
		["ritual_2"] = {
			["num_armies"]				= {{2, 3}, {1, 2}, nil}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{1, 2}, {1, 2}, nil},
			
			["army_size"]				= {10, 15},
			["character_experience"]	= {15160, 17060, 19040}, -- rank 12, 13, 14
			["unit_rank"]				= 4
		},
		
		["ritual_3"] = {
			["num_armies"]				= {{2, 2}, {1, 2}, {1, 2}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 2}, {1, 2}, nil},
			
			["army_size"]				= {15, 19},
			["character_experience"]	= {25400, 27660, 29980}, -- rank 17, 18, 19
			["unit_rank"]				= 6
		},
		
		["ritual_4"] = {
			["num_armies"]				= {{2, 4}, nil, {2, 3}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 2}, {1, 2}, nil},
			
			["army_size"]				= {15, 19},
			["character_experience"]	= {37300, 39850, 42450}, -- rank 22, 23, 24
			["unit_rank"]				= 7
		},
		
		["ritual_5"] = {
			["num_armies"]				= {nil, nil, {5, 7}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 3}, {2, 2}, nil},
			
			["army_size"]				= {19, 19},
			["character_experience"]	= {53320, 56140, 59000}, -- rank 28, 29, 30
			["unit_rank"]				= 8
		}
	},
	
	["legendary"] = {
		["ritual_1"] = {
			["num_armies"]				= {{2, 3}, nil, nil}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{1, 2}, nil, nil},
			
			["army_size"]				= {10, 15},
			["character_experience"]	= {6890, 8370, 9940}, -- rank 7, 8, 9
			["unit_rank"]				= 3
		},
		
		["ritual_2"] = {
			["num_armies"]				= {{2, 3}, {1, 2}, nil}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{1, 2}, {1, 2}, nil},
			
			["army_size"]				= {10, 15},
			["character_experience"]	= {15160, 17060, 19040}, -- rank 12, 13, 14
			["unit_rank"]				= 5
		},
		
		["ritual_3"] = {
			["num_armies"]				= {{2, 2}, {1, 2}, {1, 2}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 2}, {1, 2}, nil},
			
			["army_size"]				= {15, 19},
			["character_experience"]	= {25400, 27660, 29980}, -- rank 17, 18, 19
			["unit_rank"]				= 7
		},
		
		["ritual_4"] = {
			["num_armies"]				= {{2, 4}, nil, {2, 3}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 2}, {1, 2}, nil},
			
			["army_size"]				= {15, 19},
			["character_experience"]	= {37300, 39850, 42450}, -- rank 22, 23, 24
			["unit_rank"]				= 9
		},
		
		["ritual_5"] = {
			["num_armies"]				= {nil, nil, {5, 7}}, -- chaos, norsca, skaven
			
			["num_armies_ai"]			= {{2, 3}, {2, 2}, nil},
			
			["army_size"]				= {19, 19},
			["character_experience"]	= {53320, 56140, 59000}, -- rank 28, 29, 30
			["unit_rank"]				= 9
		}
	}
};

-- army compositions
function vortex_armies_setup()
	local ram = random_army_manager;
	
	-- chaos ritual 1
	ram:new_force("chaos_1");
	
	ram:add_mandatory_unit("chaos_1", "wh_main_chs_art_hellcannon", 1);
	ram:add_unit("chaos_1", "wh_main_chs_cav_marauder_horsemen_0", 1);
	ram:add_unit("chaos_1", "wh_main_chs_cav_marauder_horsemen_1", 1);
	ram:add_unit("chaos_1", "wh_main_chs_inf_chaos_marauders_0", 2);
	ram:add_unit("chaos_1", "wh_main_chs_inf_chaos_marauders_1", 2);
	ram:add_unit("chaos_1", "wh_main_chs_inf_chaos_warriors_0", 3);
	ram:add_unit("chaos_1", "wh_main_chs_inf_chaos_warriors_1", 3);
	ram:add_unit("chaos_1", "wh_main_chs_mon_chaos_spawn", 1);
	ram:add_unit("chaos_1", "wh_main_chs_mon_chaos_warhounds_0", 1);
	ram:add_unit("chaos_1", "wh_main_chs_mon_chaos_warhounds_1", 1);
	
	-- chaos ritual 2
	ram:new_force("chaos_2");
	
	ram:add_mandatory_unit("chaos_2", "wh_main_chs_art_hellcannon", 1);
	ram:add_unit("chaos_2", "wh_main_chs_art_hellcannon", 1);
	ram:add_unit("chaos_2", "wh_main_chs_cav_chaos_chariot", 1);
	ram:add_unit("chaos_2", "wh_main_chs_cav_chaos_knights_0", 1);
	ram:add_unit("chaos_2", "wh_main_chs_cav_chaos_knights_1", 1);
	ram:add_unit("chaos_2", "wh_main_chs_cav_marauder_horsemen_0", 1);
	ram:add_unit("chaos_2", "wh_main_chs_cav_marauder_horsemen_1", 1);
	ram:add_unit("chaos_2", "wh_main_chs_inf_chaos_marauders_0", 2);
	ram:add_unit("chaos_2", "wh_main_chs_inf_chaos_marauders_1", 2);
	ram:add_unit("chaos_2", "wh_main_chs_inf_chaos_warriors_0", 3);
	ram:add_unit("chaos_2", "wh_main_chs_inf_chaos_warriors_1", 3);
	ram:add_unit("chaos_2", "wh_main_chs_inf_chosen_0", 1);
	ram:add_unit("chaos_2", "wh_main_chs_inf_chosen_1", 1);
	ram:add_unit("chaos_2", "wh_main_chs_mon_chaos_spawn", 1);
	ram:add_unit("chaos_2", "wh_main_chs_mon_chaos_warhounds_0", 1);
	ram:add_unit("chaos_2", "wh_main_chs_mon_chaos_warhounds_1", 1);
	
	-- chaos ritual 3
	ram:new_force("chaos_3");
	
	ram:add_mandatory_unit("chaos_3", "wh_main_chs_art_hellcannon", 1);
	ram:add_unit("chaos_3", "wh_main_chs_art_hellcannon", 1);
	ram:add_unit("chaos_3", "wh_main_chs_cav_chaos_chariot", 1);
	ram:add_unit("chaos_3", "wh_main_chs_cav_chaos_knights_0", 2);
	ram:add_unit("chaos_3", "wh_main_chs_cav_chaos_knights_1", 2);
	ram:add_unit("chaos_3", "wh_main_chs_cav_marauder_horsemen_0", 1);
	ram:add_unit("chaos_3", "wh_main_chs_cav_marauder_horsemen_1", 1);
	ram:add_unit("chaos_3", "wh_main_chs_inf_chaos_warriors_0", 3);
	ram:add_unit("chaos_3", "wh_main_chs_inf_chaos_warriors_1", 3);
	ram:add_unit("chaos_3", "wh_main_chs_inf_chosen_0", 2);
	ram:add_unit("chaos_3", "wh_main_chs_inf_chosen_1", 2);
	ram:add_unit("chaos_3", "wh_main_chs_mon_chaos_spawn", 1);
	ram:add_unit("chaos_3", "wh_main_chs_mon_chaos_warhounds_1", 1);
	ram:add_unit("chaos_3", "wh_main_chs_mon_giant", 1);
	ram:add_unit("chaos_3", "wh_main_chs_mon_trolls", 1);
	
	-- chaos ritual 4
	ram:new_force("chaos_4");
	
	ram:add_mandatory_unit("chaos_4", "wh_main_chs_art_hellcannon", 1);
	ram:add_unit("chaos_4", "wh_main_chs_art_hellcannon", 1);
	ram:add_unit("chaos_4", "wh_main_chs_cav_chaos_chariot", 1);
	ram:add_unit("chaos_4", "wh_main_chs_cav_chaos_knights_0", 2);
	ram:add_unit("chaos_4", "wh_main_chs_cav_chaos_knights_1", 2);
	ram:add_unit("chaos_4", "wh_main_chs_inf_chaos_warriors_0", 1);
	ram:add_unit("chaos_4", "wh_main_chs_inf_chaos_warriors_1", 1);
	ram:add_unit("chaos_4", "wh_main_chs_inf_chosen_0", 3);
	ram:add_unit("chaos_4", "wh_main_chs_inf_chosen_1", 3);
	ram:add_unit("chaos_4", "wh_main_chs_mon_chaos_spawn", 1);
	ram:add_unit("chaos_4", "wh_main_chs_mon_chaos_warhounds_1", 1);
	ram:add_unit("chaos_4", "wh_main_chs_mon_giant", 2);
	ram:add_unit("chaos_4", "wh_main_chs_mon_trolls", 2);
	
	-- chaos ritual 5
	ram:new_force("chaos_5");
	
	ram:add_mandatory_unit("chaos_5", "wh_main_chs_art_hellcannon", 1);
	ram:add_unit("chaos_5", "wh_main_chs_art_hellcannon", 1);
	ram:add_unit("chaos_5", "wh_main_chs_cav_chaos_chariot", 1);
	ram:add_unit("chaos_5", "wh_main_chs_cav_chaos_knights_0", 2);
	ram:add_unit("chaos_5", "wh_main_chs_cav_chaos_knights_1", 2);
	ram:add_unit("chaos_5", "wh_main_chs_inf_chaos_warriors_0", 1);
	ram:add_unit("chaos_5", "wh_main_chs_inf_chaos_warriors_1", 1);
	ram:add_unit("chaos_5", "wh_main_chs_inf_chosen_0", 3);
	ram:add_unit("chaos_5", "wh_main_chs_inf_chosen_1", 3);
	ram:add_unit("chaos_5", "wh_main_chs_mon_chaos_spawn", 1);
	ram:add_unit("chaos_5", "wh_main_chs_mon_chaos_warhounds_1", 1);
	ram:add_unit("chaos_5", "wh_main_chs_mon_giant", 2);
	ram:add_unit("chaos_5", "wh_main_chs_mon_trolls", 2);
	
	-- norsca ritual 2
	ram:new_force("norsca_2");
	
	ram:add_unit("norsca_2", "wh_main_nor_cav_marauder_horsemen_0", 2);
	ram:add_unit("norsca_2", "wh_main_nor_cav_marauder_horsemen_1", 2);
	ram:add_unit("norsca_2", "wh_main_nor_inf_chaos_marauders_0", 3);
	ram:add_unit("norsca_2", "wh_main_nor_inf_chaos_marauders_1", 3);
	ram:add_unit("norsca_2", "wh_main_nor_mon_chaos_warhounds_0", 1);
	ram:add_unit("norsca_2", "wh_main_nor_mon_chaos_warhounds_1", 1);
	
	-- norsca ritual 3
	ram:new_force("norsca_3");
	
	ram:add_unit("norsca_3", "wh_main_nor_cav_chaos_chariot", 1);
	ram:add_unit("norsca_3", "wh_main_nor_cav_marauder_horsemen_0", 2);
	ram:add_unit("norsca_3", "wh_main_nor_cav_marauder_horsemen_1", 2);
	ram:add_unit("norsca_3", "wh_main_nor_inf_chaos_marauders_0", 3);
	ram:add_unit("norsca_3", "wh_main_nor_inf_chaos_marauders_1", 3);
	ram:add_unit("norsca_3", "wh_main_nor_mon_chaos_trolls", 1);
	ram:add_unit("norsca_3", "wh_main_nor_mon_chaos_warhounds_0", 1);
	ram:add_unit("norsca_3", "wh_main_nor_mon_chaos_warhounds_1", 1);
	
	-- norsca ritual 4
	ram:new_force("norsca_4");
	
	ram:add_unit("norsca_4", "wh_main_nor_cav_chaos_chariot", 1);
	ram:add_unit("norsca_4", "wh_main_nor_cav_marauder_horsemen_0", 2);
	ram:add_unit("norsca_4", "wh_main_nor_cav_marauder_horsemen_1", 2);
	ram:add_unit("norsca_4", "wh_main_nor_inf_chaos_marauders_0", 3);
	ram:add_unit("norsca_4", "wh_main_nor_inf_chaos_marauders_1", 3);
	ram:add_unit("norsca_4", "wh_main_nor_mon_chaos_trolls", 1);
	ram:add_unit("norsca_4", "wh_main_nor_mon_chaos_warhounds_0", 1);
	ram:add_unit("norsca_4", "wh_main_nor_mon_chaos_warhounds_1", 1);
	
	-- norsca ritual 5
	ram:new_force("norsca_5");
	
	ram:add_unit("norsca_5", "wh_main_nor_cav_chaos_chariot", 1);
	ram:add_unit("norsca_5", "wh_main_nor_cav_marauder_horsemen_0", 2);
	ram:add_unit("norsca_5", "wh_main_nor_cav_marauder_horsemen_1", 2);
	ram:add_unit("norsca_5", "wh_main_nor_inf_chaos_marauders_0", 3);
	ram:add_unit("norsca_5", "wh_main_nor_inf_chaos_marauders_1", 3);
	ram:add_unit("norsca_5", "wh_main_nor_mon_chaos_trolls", 1);
	ram:add_unit("norsca_5", "wh_main_nor_mon_chaos_warhounds_0", 1);
	ram:add_unit("norsca_5", "wh_main_nor_mon_chaos_warhounds_1", 1);
	
	-- skaven ritual 3
	ram:new_force("skaven_3");
	
	ram:add_mandatory_unit("skaven_3", "wh2_main_skv_art_plagueclaw_catapult", 1);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_clanrats_0", 3);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_clanrats_1", 3);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_clanrat_spearmen_0", 3);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_clanrat_spearmen_1", 3);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_death_runners_0", 1);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_gutter_runner_slingers_0", 2);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_gutter_runner_slingers_1", 2);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_gutter_runners_0", 2);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_gutter_runners_1", 2);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_night_runners_0", 2);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_night_runners_1", 2);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_plague_monks", 2);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_stormvermin_0", 2);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_stormvermin_1", 2);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_warpfire_thrower", 1);
	ram:add_unit("skaven_3", "wh2_main_skv_inf_poison_wind_globadiers", 1);
	ram:add_unit("skaven_3", "wh2_main_skv_mon_rat_ogres", 1);
	ram:add_unit("skaven_3", "wh2_main_skv_art_warp_lightning_cannon", 1);
	
	-- skaven ritual 4
	ram:new_force("skaven_4");
	
	ram:add_mandatory_unit("skaven_4", "wh2_main_skv_art_plagueclaw_catapult", 1);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_clanrats_0", 3);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_clanrats_1", 3);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_clanrat_spearmen_0", 3);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_clanrat_spearmen_1", 3);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_death_runners_0", 1);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_gutter_runner_slingers_0", 2);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_gutter_runner_slingers_1", 2);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_gutter_runners_0", 2);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_gutter_runners_1", 2);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_night_runners_0", 2);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_night_runners_1", 2);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_plague_monk_censer_bearer", 2);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_plague_monks", 2);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_stormvermin_0", 2);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_stormvermin_1", 2);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_warpfire_thrower", 1);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_poison_wind_globadiers", 1);
	ram:add_unit("skaven_4", "wh2_main_skv_inf_death_globe_bombardiers", 1);
	ram:add_unit("skaven_4", "wh2_main_skv_mon_rat_ogres", 1);
	ram:add_unit("skaven_4", "wh2_main_skv_mon_hell_pit_abomination", 1);
	ram:add_unit("skaven_4", "wh2_main_skv_art_warp_lightning_cannon", 1);
	ram:add_unit("skaven_4", "wh2_main_skv_veh_doomwheel", 1);
	
	-- skaven ritual 5
	ram:new_force("skaven_5");
	
	ram:add_mandatory_unit("skaven_5", "wh2_main_skv_art_plagueclaw_catapult", 1);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_clanrats_0", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_clanrats_1", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_clanrat_spearmen_0", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_clanrat_spearmen_1", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_death_runners_0", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_gutter_runner_slingers_0", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_gutter_runner_slingers_1", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_gutter_runners_0", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_gutter_runners_1", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_plague_monk_censer_bearer", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_plague_monks", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_stormvermin_0", 3);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_stormvermin_1", 3);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_warpfire_thrower", 1);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_poison_wind_globadiers", 1);
	ram:add_unit("skaven_5", "wh2_main_skv_inf_death_globe_bombardiers", 1);
	ram:add_unit("skaven_5", "wh2_main_skv_mon_rat_ogres", 2);
	ram:add_unit("skaven_5", "wh2_main_skv_mon_hell_pit_abomination", 1);
	ram:add_unit("skaven_5", "wh2_main_skv_art_warp_lightning_cannon", 1);
	ram:add_unit("skaven_5", "wh2_main_skv_veh_doomwheel", 1);
end;
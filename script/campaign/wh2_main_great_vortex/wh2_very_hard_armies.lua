-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	VERY HARD ARMIES
--	Adds armies, units and treasury etc. when on Very Hard or Legendary (SP only)
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------


function add_very_hard_armies()	
	if cm:model():combined_difficulty_level() > -2 then
		return;
	end;
	
	out("* add_very_hard_armies() is adding extra enemies, combined difficulty level is " .. cm:model():combined_difficulty_level());
	
	-- tyrion
	if cm:get_faction("wh2_main_hef_eataine"):is_human() then
		-- cult of excess
		create_new_very_hard_armies(
			"wh2_main_def_cult_of_excess",
			{
				{
					533,
					422,
					"wh2_main_def_dreadlord",
					"names_name_2147359511",
					"",
					{
						"wh2_main_def_inf_dreadspears_0",
						"wh2_main_def_inf_dreadspears_0",
						"wh2_main_def_inf_dreadspears_0",
						"wh2_main_def_cav_dark_riders_0",
						"wh2_main_def_inf_bleakswords_0",
						"wh2_main_def_inf_bleakswords_0",
						"wh2_main_def_inf_darkshards_0",
						"wh2_main_def_inf_darkshards_0",
						"wh2_main_def_inf_darkshards_0"
					}
				}
			}
		);
		
		-- caledor
		add_very_hard_units_to_existing_army(
			"wh2_main_hef_caledor",
			452,
			407,
			{
				"wh2_main_hef_cav_dragon_princes",
				"wh2_main_hef_cav_dragon_princes"
			}
		);
		
		-- saphery
		add_very_hard_units_to_existing_army(
			"wh2_main_hef_saphery",
			598,
			503,
			{
				"wh2_main_hef_inf_swordmasters_of_hoeth_0",
				"wh2_main_hef_inf_swordmasters_of_hoeth_0"
			}
		);
		
		-- pirates of sartosa
		-- add_very_hard_units_to_existing_army(
			-- "wh2_main_emp_pirates_of_sartosa",
			-- 701,
			-- 401,
			-- {
				-- "wh_main_emp_art_mortar",
				-- "wh_main_emp_art_mortar",
				-- "wh_main_emp_cav_outriders_0",
				-- "wh_main_emp_cav_outriders_0"
			-- }
		-- );
		
		-- skaeling
		create_new_very_hard_armies(
			"wh_main_nor_skaeling",
			{
				{
					714,
					580,
					"nor_marauder_chieftain",
					"names_name_2147345667",
					"names_name_2147356342",
					{
						"wh_main_nor_inf_chaos_marauders_0",
						"wh_main_nor_inf_chaos_marauders_0",
						"wh_main_nor_inf_chaos_marauders_0",
						"wh_main_nor_inf_chaos_marauders_0",
						"wh_main_nor_cav_marauder_horsemen_0",
						"wh_main_nor_cav_marauder_horsemen_0",
						"wh_main_nor_mon_chaos_warhounds_0",
						"wh_main_nor_mon_chaos_warhounds_0"
					}
				}
			}
		);
		
		-- scourge of khaine
		cm:treasury_mod("wh2_main_def_scourge_of_khaine", 20000);
		
		add_very_hard_units_to_existing_army(
			"wh2_main_def_scourge_of_khaine",
			506,
			585,
			{
				"wh2_main_def_art_reaper_bolt_thrower",
				"wh2_main_def_art_reaper_bolt_thrower",
				"wh2_main_def_inf_har_ganeth_executioners_0",
				"wh2_main_def_inf_har_ganeth_executioners_0"
			}
		);
		
		add_very_hard_units_to_existing_army(
			"wh2_main_def_scourge_of_khaine",
			483,
			608,
			{
				"wh2_main_def_art_reaper_bolt_thrower",
				"wh2_main_def_art_reaper_bolt_thrower",
				"wh2_main_def_inf_bleakswords_0",
				"wh2_main_def_inf_bleakswords_0"
			}
		);
	end;
	
	-- teclis
	if cm:get_faction("wh2_main_hef_order_of_loremasters"):is_human() then
		-- blood hall coven
		add_very_hard_units_to_existing_army(
			"wh2_main_def_blood_hall_coven",
			41,
			185,
			{
				"wh2_main_def_art_reaper_bolt_thrower",
				"wh2_main_def_inf_witch_elves_0",
				"wh2_main_def_inf_witch_elves_0"
			}
		);
		
		add_very_hard_units_to_existing_army(
			"wh2_main_def_blood_hall_coven",
			98,
			153,
			{
				"wh2_main_def_cav_dark_riders_1",
				"wh2_main_def_cav_dark_riders_1"
			}
		);
		
		-- scourge of khaine
		cm:treasury_mod("wh2_main_def_scourge_of_khaine", 20000);
		
		add_very_hard_units_to_existing_army(
			"wh2_main_def_scourge_of_khaine",
			506,
			585,
			{
				"wh2_main_def_art_reaper_bolt_thrower",
				"wh2_main_def_art_reaper_bolt_thrower",
				"wh2_main_def_inf_har_ganeth_executioners_0",
				"wh2_main_def_inf_har_ganeth_executioners_0"
			}
		);
		
		add_very_hard_units_to_existing_army(
			"wh2_main_def_scourge_of_khaine",
			483,
			608,
			{
				"wh2_main_def_art_reaper_bolt_thrower",
				"wh2_main_def_art_reaper_bolt_thrower",
				"wh2_main_def_inf_bleakswords_0",
				"wh2_main_def_inf_bleakswords_0"
			}
		);
		
		-- sentinels of xeti
		add_very_hard_units_to_existing_army(
			"wh2_main_lzd_sentinels_of_xeti",
			110,
			127,
			{
				"wh2_main_lzd_mon_bastiladon_0"
			}
		);
		
		create_new_very_hard_armies(
			"wh2_main_lzd_sentinels_of_xeti",
			{
				{
					54,
					133,
					"wh2_main_lzd_saurus_old_blood",
					"names_name_988230570",
					"",
					{
						"wh2_main_lzd_inf_skink_skirmishers_0",
						"wh2_main_lzd_inf_skink_skirmishers_0",
						"wh2_main_lzd_inf_skink_skirmishers_0",
						"wh2_main_lzd_inf_skink_cohort_0",
						"wh2_main_lzd_inf_skink_cohort_0",
						"wh2_main_lzd_inf_skink_cohort_0",
						"wh2_main_lzd_inf_skink_cohort_0",
						"wh2_main_lzd_inf_saurus_warriors_0",
						"wh2_main_lzd_inf_saurus_warriors_0",
						"wh2_main_lzd_inf_saurus_spearmen_0",
						"wh2_main_lzd_inf_saurus_spearmen_0"
					}
				}
			}
		);
		
		-- clan skryre
		if cm:get_faction("wh2_main_skv_clan_skyre"):is_human() == false then
			cm:treasury_mod("wh2_main_skv_clan_skyre", 10000);
			
			create_new_very_hard_armies(
				"wh2_main_skv_clan_skyre",
				{
					{
						104,
						203,
						"wh2_main_skv_warlord",
						"names_name_2147360577",
						"",
						{
							"wh2_main_skv_art_plagueclaw_catapult",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_gutter_runners_0",
							"wh2_main_skv_inf_gutter_runners_0"
						}
					},
					{
						109,
						173,
						"wh2_main_skv_warlord",
						"names_name_1947316870",
						"",
						{
							"wh2_main_skv_art_plagueclaw_catapult",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_gutter_runners_0",
							"wh2_main_skv_inf_gutter_runners_0"
						}
					}
				}
			);
			
			cm:transfer_region_to_faction("wh2_main_vor_northern_spine_of_sotek_cavern_of_the_mlexigaur", "wh2_main_skv_clan_skyre");
			cm:transfer_region_to_faction("wh2_main_vor_northern_spine_of_sotek_hualotal", "wh2_main_skv_clan_skyre");
		end
		-- clan pestilens
		if cm:get_faction("wh2_main_skv_clan_pestilens"):is_human() == false then
			cm:treasury_mod("wh2_main_skv_clan_pestilens", 10000);
			
			create_new_very_hard_armies(
				"wh2_main_skv_clan_pestilens",
				{
					{
						253,
						90,
						"wh2_main_skv_warlord",
						"names_name_1998208517",
						"",
						{
							"wh2_main_skv_art_plagueclaw_catapult",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_clanrats_0",
							"wh2_main_skv_inf_plague_monks",
							"wh2_main_skv_inf_plague_monks"
						}
					}
				}
			);
			
			cm:transfer_region_to_faction("wh2_main_vor_the_lost_valleys_the_sentinel_of_time", "wh2_main_skv_clan_pestilens");
		end
	end;
	
	-- lord skrolk
	if cm:get_faction("wh2_main_skv_clan_pestilens"):is_human() then
		-- southern sentinels
		add_very_hard_units_to_existing_army(
			"wh2_main_lzd_southern_sentinels",
			274,
			76,
			{
				"wh2_main_lzd_inf_saurus_warriors_0",
				"wh2_main_lzd_inf_saurus_warriors_0",
				"wh2_main_lzd_cav_cold_ones_1",
				"wh2_main_lzd_cav_cold_ones_1"
			}
		);
		
		create_new_very_hard_armies(
			"wh2_main_lzd_southern_sentinels",
			{
				{
					193,
					117,
					"wh2_main_lzd_saurus_old_blood",
					"names_name_1437874874",
					"",
					{
						"wh2_main_lzd_inf_skink_skirmishers_0",
						"wh2_main_lzd_inf_skink_skirmishers_0",
						"wh2_main_lzd_inf_skink_skirmishers_0",
						"wh2_main_lzd_inf_skink_skirmishers_0",
						"wh2_main_lzd_inf_saurus_warriors_0",
						"wh2_main_lzd_inf_saurus_warriors_0",
						"wh2_main_lzd_cav_cold_ones_1",
						"wh2_main_lzd_cav_cold_ones_1",
						"wh2_main_lzd_inf_skink_cohort_0",
						"wh2_main_lzd_inf_skink_cohort_0",
						"wh2_main_lzd_inf_skink_cohort_0",
						"wh2_main_lzd_inf_skink_cohort_0"
					}
				}
			}
		);
		
		-- itza
		if cm:get_faction("wh2_main_lzd_itza"):is_human() == false then
			cm:treasury_mod("wh2_main_lzd_itza", 20000);
			
			add_very_hard_units_to_existing_army(
				"wh2_main_lzd_itza",
				190,
				179,
				{
					"wh2_main_lzd_inf_temple_guards",
					"wh2_main_lzd_inf_temple_guards",
					"wh2_main_lzd_mon_stegadon_0"
				}
			);
			
			create_new_very_hard_armies(
				"wh2_main_lzd_itza",
				{
					{
						233,
						194,
						"wh2_main_lzd_saurus_old_blood",
						"names_name_1437874874",
						"",
						{
							"wh2_main_lzd_inf_chameleon_skinks_0",
							"wh2_main_lzd_inf_chameleon_skinks_0",
							"wh2_main_lzd_inf_chameleon_skinks_0",
							"wh2_main_lzd_inf_saurus_warriors_1",
							"wh2_main_lzd_inf_saurus_warriors_1",
							"wh2_main_lzd_inf_saurus_warriors_1"
						}
					},
					{
						219,
						206,
						"wh2_main_lzd_saurus_old_blood",
						"names_name_12361275",
						"",
						{
							"wh2_main_lzd_inf_chameleon_skinks_0",
							"wh2_main_lzd_inf_chameleon_skinks_0",
							"wh2_main_lzd_inf_chameleon_skinks_0",
							"wh2_main_lzd_inf_saurus_warriors_1",
							"wh2_main_lzd_inf_saurus_warriors_1",
							"wh2_main_lzd_inf_saurus_warriors_1"
						}
					}
				}
			);
			
			cm:transfer_region_to_faction("wh2_main_vor_river_qurveza_axlotl", "wh2_main_lzd_itza");
			cm:transfer_region_to_faction("wh2_main_vor_northern_great_jungle_quetza", "wh2_main_lzd_itza");
		end
		
		-- tlaxtlan
		create_new_very_hard_armies(
			"wh2_main_lzd_tlaxtlan",
			{
				{
					130,
					279,
					"wh2_main_lzd_saurus_old_blood",
					"names_name_1397995694",
					"",
					{
						"wh2_main_lzd_inf_chameleon_skinks_0",
						"wh2_main_lzd_inf_chameleon_skinks_0",
						"wh2_main_lzd_inf_skink_cohort_0",
						"wh2_main_lzd_inf_skink_cohort_0"
					}
				}
			}
		);
		
		cm:transfer_region_to_faction("wh2_main_vor_the_creeping_jungle_tlanxla", "wh2_main_lzd_tlaxtlan");
		
		-- spine of sotek dwarfs
		create_new_very_hard_armies(
			"wh2_main_dwf_spine_of_sotek_dwarfs",
			{
				{
					200,
					85,
					"dwf_lord",
					"names_name_2147354311",
					"names_name_2147358985",
					{
						"wh_main_dwf_inf_dwarf_warrior_0",
						"wh_main_dwf_inf_dwarf_warrior_0",
						"wh_main_dwf_inf_quarrellers_0",
						"wh_main_dwf_inf_quarrellers_0"
					}
				}
			}
		);
	end;
	
	-- queek headtaker
	if cm:get_faction("wh2_main_skv_clan_mors"):is_human() then
		-- fortress of dawn
		add_very_hard_units_to_existing_army(
			"wh2_main_hef_fortress_of_dawn",
			528,
			76,
			{
				"wh2_main_hef_inf_spearmen_0",
				"wh2_main_hef_inf_spearmen_0",
				"wh2_main_hef_inf_archers_0",
				"wh2_main_hef_inf_archers_0",
				"wh2_main_hef_inf_lothern_sea_guard_0",
				"wh2_main_hef_inf_lothern_sea_guard_0"
			}
		);
		
		create_new_very_hard_armies(
			"wh2_main_hef_fortress_of_dawn",
			{
				{
					563,
					43,
					"wh2_main_hef_prince",
					"names_name_2147359524",
					"",
					{
						"wh2_main_hef_inf_spearmen_0",
						"wh2_main_hef_inf_spearmen_0",
						"wh2_main_hef_inf_lothern_sea_guard_0",
						"wh2_main_hef_inf_lothern_sea_guard_0",
						"wh2_main_hef_cav_silver_helms_0",
						"wh2_main_hef_cav_silver_helms_0"
					}
				}
			}
		);
		
		-- clan moulder
		add_very_hard_units_to_existing_army(
			"wh2_dlc16_skv_clan_gritus",
			593,
			58,
			{
				"wh2_main_skv_mon_rat_ogres"
			}
		);
		
		-- last defenders
		if cm:get_faction("wh2_main_lzd_last_defenders"):is_human() == false then
			cm:treasury_mod("wh2_main_lzd_last_defenders", 10000);
			
			add_very_hard_units_to_existing_army(
				"wh2_main_lzd_last_defenders",
				671,
				150,
				{
					"wh2_main_lzd_cav_cold_ones_1",
					"wh2_main_lzd_cav_cold_ones_1"
				}
			);
			
			create_new_very_hard_armies(
				"wh2_main_lzd_last_defenders",
				{
					{
						705,
						179,
						"wh2_main_lzd_saurus_old_blood",
						"names_name_1611670727",
						"",
						{
							"wh2_main_lzd_inf_skink_skirmishers_0",
							"wh2_main_lzd_inf_skink_skirmishers_0",
							"wh2_main_lzd_inf_saurus_warriors_1",
							"wh2_main_lzd_inf_saurus_warriors_1"
						}
					}
				}
			);
			
			cm:transfer_region_to_faction("wh2_main_vor_kingdom_of_beasts_the_cursed_jungle", "wh2_main_lzd_last_defenders");
		end
		
		-- zlatan
		cm:treasury_mod("wh2_main_lzd_zlatan", 10000);
		
		create_new_very_hard_armies(
			"wh2_main_lzd_zlatan",
			{
				{
					530,
					147,
					"wh2_main_lzd_saurus_old_blood",
					"names_name_1802062932",
					"",
					{
						"wh2_main_lzd_inf_skink_skirmishers_0",
						"wh2_main_lzd_inf_skink_skirmishers_0",
						"wh2_main_lzd_inf_saurus_warriors_1",
						"wh2_main_lzd_inf_saurus_warriors_1"
					}
				}
			}
		);
	end;
	
	-- kroq-gar
	if cm:get_faction("wh2_main_lzd_last_defenders"):is_human() then
		-- tlaqua
		if cm:get_faction("wh2_main_lzd_tlaqua"):is_human() == false then
			cm:treasury_mod("wh2_main_lzd_tlaqua", 20000);
			
			add_very_hard_units_to_existing_army(
				"wh2_main_lzd_tlaqua",
				525,
				188,
				{
					"wh2_main_lzd_mon_bastiladon_0"
				}
			);
			
			create_new_very_hard_armies(
				"wh2_main_lzd_tlaqua",
				{
					{
						494,
						191,
						"wh2_main_lzd_saurus_old_blood",
						"names_name_1129661942",
						"",
						{
							"wh2_main_lzd_inf_skink_skirmishers_0",
							"wh2_main_lzd_inf_skink_skirmishers_0",
							"wh2_main_lzd_inf_saurus_warriors_1",
							"wh2_main_lzd_inf_saurus_warriors_1"
						}
					},
					{
						582,
						167,
						"wh2_main_lzd_saurus_old_blood",
						"names_name_1022176898",
						"",
						{
							"wh2_main_lzd_inf_saurus_spearmen_0",
							"wh2_main_lzd_inf_saurus_spearmen_0",
							"wh2_main_lzd_inf_saurus_spearmen_0",
							"wh2_main_lzd_inf_chameleon_skinks_0",
							"wh2_main_lzd_inf_chameleon_skinks_0",
							"wh2_main_lzd_inf_chameleon_skinks_0"
						}
					}
				}
			);
			
			cm:transfer_region_to_faction("wh2_main_vor_western_jungles_deaths-head_monoliths", "wh2_main_lzd_tlaqua");
		end
		-- clan mordkin
		add_very_hard_units_to_existing_army(
			"wh2_main_skv_clan_mordkin",
			634,
			92,
			{
				"wh2_main_skv_mon_rat_ogres",
				"wh2_main_skv_inf_night_runners_0",
				"wh2_main_skv_inf_night_runners_0"
			}
		);
		
		add_very_hard_units_to_existing_army(
			"wh2_main_skv_clan_mordkin",
			655,
			131,
			{
				"wh2_main_skv_inf_clanrat_spearmen_1",
				"wh2_main_skv_inf_clanrat_spearmen_1",
				"wh2_main_skv_inf_stormvermin_0",
				"wh2_main_skv_inf_stormvermin_0",
				"wh2_main_skv_inf_skavenslave_slingers_0",
				"wh2_main_skv_inf_skavenslave_slingers_0",
				"wh2_main_skv_inf_skavenslave_slingers_0",
				"wh2_main_skv_inf_skavenslave_slingers_0",
				"wh2_main_skv_inf_clanrats_1",
				"wh2_main_skv_inf_clanrats_1",
				"wh2_main_skv_inf_clanrats_1"
			}
		);
		
		-- clan moulder
		add_very_hard_units_to_existing_army(
			"wh2_main_skv_clan_moulder",
			593,
			58,
			{
				"wh2_main_skv_mon_rat_ogres"
			}
		);
	end;
	
	-- lord mazdamundi
	if cm:get_faction("wh2_main_lzd_hexoatl"):is_human() then
		-- skeggi
		add_very_hard_units_to_existing_army(
			"wh2_main_nor_skeggi",
			182,
			375,
			{
				"wh_main_nor_mon_chaos_trolls",
				"wh_main_nor_cav_marauder_horsemen_0"
			}
		);
		
		create_new_very_hard_armies(
			"wh2_main_nor_skeggi",
			{
				{
					151,
					379,
					"nor_marauder_chieftain",
					"names_name_2147356489",
					"names_name_2147356413",
					{
						"wh_main_nor_cav_chaos_chariot",
						"wh_main_nor_mon_chaos_warhounds_0",
						"wh_main_nor_mon_chaos_warhounds_0",
						"wh_main_nor_inf_chaos_marauders_0",
						"wh_main_nor_inf_chaos_marauders_0",
						"wh_main_nor_inf_chaos_marauders_0",
						"wh_main_nor_inf_chaos_marauders_0",
						"wh_main_nor_cav_marauder_horsemen_0",
						"wh_main_nor_cav_marauder_horsemen_0"
					}
				}
			}
		);
		
		-- blue vipers
		create_new_very_hard_armies(
			"wh2_main_grn_blue_vipers",
			{
				{
					90,
					313,
					"grn_orc_warboss",
					"names_name_2147355546",
					"",
					{
						"wh_main_grn_inf_savage_orc_arrer_boyz",
						"wh_main_grn_inf_savage_orc_arrer_boyz",
						"wh_main_grn_inf_savage_orcs",
						"wh_main_grn_inf_savage_orcs",
						"wh_main_grn_inf_savage_orcs"
					}
				}
			}
		);
		
		cm:transfer_region_to_faction("wh2_main_vor_jungle_of_pahualaxa_floating_pyramid", "wh2_main_grn_blue_vipers");
		
		-- ss’ildra tor
		create_new_very_hard_armies(
			"wh2_main_def_ssildra_tor",
			{
				{
					68,
					474,
					"wh2_main_def_dreadlord",
					"names_name_2147359527",
					"",
					{
						"wh2_main_def_inf_bleakswords_0",
						"wh2_main_def_inf_bleakswords_0",
						"wh2_main_def_inf_darkshards_1",
						"wh2_main_def_inf_darkshards_1"
					}
				}
			}
		);
		
		cm:transfer_region_to_faction("wh2_main_vor_grey_guardians_grey_rock_point", "wh2_main_def_ssildra_tor");
		cm:transfer_region_to_faction("wh2_main_vor_grey_guardians_titan_peak", "wh2_main_def_ssildra_tor");
		
		-- cult of pleasure
		if cm:get_faction("wh2_main_def_cult_of_pleasure"):is_human() == false then
			cm:treasury_mod("wh2_main_def_cult_of_pleasure", 10000);
			
			add_very_hard_units_to_existing_army(
				"wh2_main_def_cult_of_pleasure",
				143,
				520,
				{
					"wh2_main_def_mon_war_hydra_0",
					"wh2_main_def_cav_dark_riders_2",
					"wh2_main_def_cav_dark_riders_2",
					"wh2_main_def_cav_dark_riders_2",
					"wh2_main_def_inf_darkshards_1",
					"wh2_main_def_inf_darkshards_1",
					"wh2_main_def_inf_darkshards_1"
				}
			);
			
			create_new_very_hard_armies(
				"wh2_main_def_cult_of_pleasure",
				{
					{
						165,
						495,
						"wh2_main_def_dreadlord",
						"names_name_2001547846",
						"",
						{
							"wh2_main_def_inf_bleakswords_0",
							"wh2_main_def_inf_bleakswords_0",
							"wh2_main_def_inf_bleakswords_0",
							"wh2_main_def_inf_darkshards_1",
							"wh2_main_def_art_reaper_bolt_thrower"
						}
					}
				}
			);
		end
	end;
	
	-- malekith
	if cm:get_faction("wh2_main_def_naggarond"):is_human() then
		-- clan septik
		add_very_hard_units_to_existing_army(
			"wh2_main_skv_clan_septik",
			199,
			654,
			{
				"wh2_main_skv_inf_clanrat_spearmen_0",
				"wh2_main_skv_inf_clanrats_0",
				"wh2_main_skv_inf_clanrats_0",
				"wh2_main_skv_inf_stormvermin_0",
				"wh2_main_skv_inf_stormvermin_0",
				"wh2_main_skv_inf_night_runners_0",
				"wh2_main_skv_inf_night_runners_0"
			}
		);
		
		-- ghrond
		add_very_hard_units_to_existing_army(
			"wh2_main_def_ghrond",
			244,
			668,
			{
				"wh2_main_def_cav_dark_riders_2",
				"wh2_main_def_cav_dark_riders_2",
				"wh2_main_def_art_reaper_bolt_thrower"
			}
		);
	end;
	
	-- morathi
	if cm:get_faction("wh2_main_def_cult_of_pleasure"):is_human() then
		-- bleak holds
		add_very_hard_units_to_existing_army(
			"wh2_main_def_bleak_holds",
			206,
			511,
			{
				"wh2_main_def_inf_shades_1",
				"wh2_main_def_inf_shades_1"
			}
		);
		
		add_very_hard_units_to_existing_army(
			"wh2_main_def_bleak_holds",
			125,
			519,
			{
				"wh2_main_def_inf_shades_1",
				"wh2_main_def_inf_shades_1",
				"wh2_main_def_inf_bleakswords_0",
				"wh2_main_def_inf_bleakswords_0",
				"wh2_main_def_inf_darkshards_0",
				"wh2_main_def_inf_darkshards_0",
				"wh2_main_def_art_reaper_bolt_thrower"
			}
		);
		
		-- hexoatl
		if cm:get_faction("wh2_main_def_cult_of_pleasure"):is_human() == false then
			cm:treasury_mod("wh2_main_lzd_hexoatl", 10000);
			
			create_new_very_hard_armies(
				"wh2_main_lzd_hexoatl",
				{
					{
						57,
						371,
						"wh2_main_lzd_saurus_old_blood",
						"names_name_1042552047",
						"",
						{
							"wh2_main_lzd_inf_skink_skirmishers_0",
							"wh2_main_lzd_inf_skink_skirmishers_0",
							"wh2_main_lzd_inf_saurus_warriors_1",
							"wh2_main_lzd_inf_saurus_warriors_1"
						}
					}
				}
			);
			
			cm:transfer_region_to_faction("wh2_main_vor_coast_of_squalls_macu_peaks", "wh2_main_lzd_hexoatl");
		end
		
		-- tiranoc
		add_very_hard_units_to_existing_army(
			"wh2_main_hef_tiranoc",
			255,
			477,
			{
				"wh2_main_hef_cav_tiranoc_chariot",
				"wh2_main_hef_cav_tiranoc_chariot"
			}
		);
	end;
end;





function add_very_hard_units_to_existing_army(faction_name, x, y, units)
	local cqi = cm:get_closest_general_to_position_from_faction(faction_name, x, y, false):cqi();
	
	if cqi then
		for i = 1, #units do
			cm:grant_unit_to_character(cm:char_lookup_str(cqi), units[i]);
		end;
	end;
end;

function create_new_very_hard_armies(faction_name, armies)
	for i = 1, #armies do
		local current_army = armies[i];
		local units_string = "";
		local units_table = current_army[6];
		
		-- convert the table of units to a single string
		for j = 1, #units_table do
			units_string = units_string .. units_table[j]
			
			if j < #units_table then
				units_string = units_string .. ",";
			end;
		end;
		
		cm:create_force_with_general(
			faction_name,											-- faction name
			units_string,											-- units string
			"wh2_main_vor_straits_of_lothern_tower_of_lysean",		-- a region name
			current_army[1],										-- x
			current_army[2],										-- y
			"general",												-- general character type
			current_army[3],										-- general character subtype
			current_army[4],										-- forename
			"",														-- clan name
			current_army[5],										-- family name
			"",														-- title
			false													-- make faction leader
		);
	end;
end;
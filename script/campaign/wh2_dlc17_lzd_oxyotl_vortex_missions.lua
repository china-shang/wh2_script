Oxyotl_Vortex = {
	-- Additional variables
	oxyotl_faction_key = "wh2_dlc17_lzd_oxyotl",
	threat_map_script_event = "ScriptEventOxyThreatMapSuccess",
	mission_text_prefix = "mission_text_text_",
	oxyotl_final_battle = "wh2_dlc17_qb_lzd_final_battle_oxyotl",
	mission_intervention = nil,
	start_chain_number = 1,

	-- Single Mission progress completion counter
	mission_counter = 0,

	-- Mission chain number
	mission_chain_1 = 1,
	mission_chain_2 = 2,
	mission_chain_3 = 3,

	-- Mission chain variables
	mission_chain = {
		{
			-- Vortex mission chain keys
			vortex_mission_key = "wh2_dlc17_lzd_oxyotl_vortex_narrative_1",
			-- Mission reward keys
			reward_key = "wh2_dlc17_lzd_oxyotl_vortex_narrative_1",
			-- Mission reward payloads
			vortex_mission_rewards = {
				"money 2500",
				"faction_pooled_resource_transaction{resource lzd_sanctum_points;factor wh2_dlc17_resource_factor_sanctum_sets_gained;amount 1;}",
				"effect_bundle{bundle_key wh2_dlc17_oxyotl_vortex_narrative_reward_1;turns 0;}",
			},
			-- Mission description keys
			update_mission_desc_key = "wh2_dlc17_lzd_oxyotl_vortex_narrative_1",
			-- Mission completion requirements
			vortex_mission_req = 3,
			mission_complete = false,
		},
		{
			-- Vortex mission chain keys
			vortex_mission_key = "wh2_dlc17_lzd_oxyotl_vortex_narrative_2",
			-- Mission reward keys
			reward_key = "wh2_dlc17_lzd_oxyotl_vortex_narrative_2",
			-- Mission reward payloads
			vortex_mission_rewards = {
				"money 5000",
				"faction_pooled_resource_transaction{resource lzd_sanctum_points;factor wh2_dlc17_resource_factor_sanctum_sets_gained;amount 1;}",
				"effect_bundle{bundle_key wh2_dlc17_oxyotl_vortex_narrative_reward_2;turns 0;}",
			},
			-- Mission description keys
			update_mission_desc_key = "wh2_dlc17_lzd_oxyotl_vortex_narrative_2",
			-- Mission completion requirements
			vortex_mission_req = 6,
			-- Previous effect bundle to be replaced with new one
			previous_effect_bundle = "wh2_dlc17_oxyotl_vortex_narrative_reward_1",
			mission_complete = false,
		},
		{
			-- Vortex mission chain keys
			vortex_mission_key = "wh2_dlc17_lzd_oxyotl_vortex_narrative_3",
			-- Mission reward keys
			reward_key = "wh2_dlc17_lzd_oxyotl_vortex_narrative_3",
			-- Mission reward payloads
			vortex_mission_rewards = {
				"money 7500",
				"faction_pooled_resource_transaction{resource lzd_sanctum_points;factor wh2_dlc17_resource_factor_sanctum_sets_gained;amount 1;}",
				"effect_bundle{bundle_key wh2_dlc17_oxyotl_vortex_narrative_reward_3;turns 0;}",
			},
			-- Mission description keys
			update_mission_desc_key = "wh2_dlc17_lzd_oxyotl_vortex_narrative_3",
			-- Mission completion requirements
			vortex_mission_req = 11,
			-- Previous effect bundle to be replaced with new one
			previous_effect_bundle = "wh2_dlc17_oxyotl_vortex_narrative_reward_2",
			mission_complete = false,
		},
	},
}

function Oxyotl_Vortex:update_mission_progress(mission_key, update_mission_desc_key, mission_progress_value, m_manager)
	out.design("Update Mission progress description")
	out.inc_tab("design")

	out.design("Mission Key: "..mission_key)
	out.design("Description Key: "..update_mission_desc_key)
	out.design("Mission Progress: "..mission_progress_value)

	local new_mission_text = self.mission_text_prefix..update_mission_desc_key.."_"..mission_progress_value
	out.design("Mission Text Key: "..new_mission_text)
	m_manager:update_scripted_objective_text(new_mission_text, mission_key)

	out.dec_tab("design")
	out.design("------------------------------------------------------------------------------------------------------------------------------")
	out.design("------------------------------------------------------------------------------------------------------------------------------")
end

function Oxyotl_Vortex:trigger_starting_vortex_mission()
	if(cm:is_multiplayer() == false) then
		local faction = cm:get_faction(self.oxyotl_faction_key)
		if faction:is_human() then
			if cm:is_new_game() then
				self.mission_intervention = intervention:new(
					"oxyotl_missions",
					10,
					function()
						self.mission_intervention:complete()
						Oxy_nm_1:trigger()
					end
				)

				self.mission_intervention:add_trigger_condition(
					"ScriptEventOxyVortexMissionStart",
					function(context)
						return true
					end
				)

				self.mission_intervention:start()
				core:trigger_event("ScriptEventOxyVortexMissionStart")
			end

			-- Setting up narrative missions
			-- Narrative mission 1
			local mission_setup = self.mission_chain[self.mission_chain_1]
			local mission_text = self.mission_text_prefix .. mission_setup.vortex_mission_key
			Oxy_nm_1 = mission_manager:new(self.oxyotl_faction_key, mission_setup.vortex_mission_key)
			Oxy_nm_1:add_new_scripted_objective(
				mission_text,
				self.threat_map_script_event,
				function(context)
					if not mission_setup.mission_complete then
						self.mission_counter = self.mission_counter + 1
						self:update_mission_progress(mission_setup.vortex_mission_key, mission_setup.update_mission_desc_key, self.mission_counter, Oxy_nm_1)
						if self.mission_counter >= mission_setup.vortex_mission_req then
							-- Mission completed
							self.mission_counter = 0
							Oxy_nm_2:trigger()
							-- Replace Effect bundle from previous mission reward with new reward bundle
							local mission_data = self.mission_chain[self.mission_chain_1]
							if mission_data.previous_effect_bundle ~= nil then
								cm:remove_effect_bundle(mission_data.previous_effect_bundle, self.oxyotl_faction_key)
							end
							-- Complete mission
							self.mission_chain[self.mission_chain_1].mission_complete = true
							return true
						else
							return false
						end
					end
				end,
				mission_setup.vortex_mission_key
			)
			for i = 1, #mission_setup.vortex_mission_rewards do
				out.design("Reward Payload: "..mission_setup.vortex_mission_rewards[i])
				Oxy_nm_1:add_payload(mission_setup.vortex_mission_rewards[i])
			end
			-- Set Mission Issuer
			Oxy_nm_1:set_mission_issuer("YUKANNADOOZAT");
			-- Trigger mission
			Oxy_nm_1:set_should_whitelist(false)

			-- Narrative mission 2
			local mission_setup_2 = self.mission_chain[self.mission_chain_2]
			local mission_text_2 = self.mission_text_prefix .. mission_setup_2.vortex_mission_key
			Oxy_nm_2 = mission_manager:new(self.oxyotl_faction_key, mission_setup_2.vortex_mission_key)
			Oxy_nm_2:add_new_scripted_objective(
				mission_text_2,
				self.threat_map_script_event,
				function(context)
					if not mission_setup_2.mission_complete then
						self.mission_counter = self.mission_counter + 1
						self:update_mission_progress(mission_setup_2.vortex_mission_key, mission_setup_2.update_mission_desc_key, self.mission_counter, Oxy_nm_2)
						if self.mission_counter >= mission_setup_2.vortex_mission_req then
							-- Mission completed
							self.mission_counter = 0
							-- Check and setup next mission in chain
							Oxy_nm_3:trigger()
							local mission_data = self.mission_chain[self.mission_chain_2]
							if mission_data.previous_effect_bundle ~= nil then
								cm:remove_effect_bundle(mission_data.previous_effect_bundle, self.oxyotl_faction_key)
							end
							self.mission_chain[self.mission_chain_2].mission_complete = true
							return true
						else
							return false
						end
					end
				end,
				mission_setup_2.vortex_mission_key
			)
			for i = 1, #mission_setup_2.vortex_mission_rewards do
				out.design("Reward Payload: "..mission_setup_2.vortex_mission_rewards[i])
				Oxy_nm_2:add_payload(mission_setup_2.vortex_mission_rewards[i])
			end
			-- Set Mission Issuer
			Oxy_nm_2:set_mission_issuer("YUKANNADOOZAT");
			-- Trigger mission
			Oxy_nm_2:set_should_whitelist(false)

			-- Narrative mission 3
			local mission_setup_3 = self.mission_chain[self.mission_chain_3]
			local mission_text_3 = self.mission_text_prefix .. mission_setup_3.vortex_mission_key
			Oxy_nm_3 = mission_manager:new(self.oxyotl_faction_key, mission_setup_3.vortex_mission_key)
			Oxy_nm_3:add_new_scripted_objective(
				mission_text_3,
				self.threat_map_script_event,
				function(context)
					if not mission_setup_3.mission_complete then
						self.mission_counter = self.mission_counter + 1
						self:update_mission_progress(mission_setup_3.vortex_mission_key, mission_setup_3.update_mission_desc_key, self.mission_counter, Oxy_nm_3)
						if self.mission_counter >= mission_setup_3.vortex_mission_req then
							-- Replace Effect bundle from previous mission reward with new reward bundle
							local mission_data = self.mission_chain[self.mission_chain_3]
							if mission_data.previous_effect_bundle ~= nil then
								cm:remove_effect_bundle(mission_data.previous_effect_bundle, self.oxyotl_faction_key)
							end
							-- Trigger final battle mission
							cm:trigger_mission(self.oxyotl_faction_key, self.oxyotl_final_battle, true)
							self.mission_chain[self.mission_chain_3].mission_complete = true
							return true
						else
							return false
						end
					end
				end,
				mission_setup_3.vortex_mission_key
			)
			for i = 1, #mission_setup_3.vortex_mission_rewards do
				out.design("Reward Payload: "..mission_setup_3.vortex_mission_rewards[i])
				Oxy_nm_3:add_payload(mission_setup_3.vortex_mission_rewards[i])
			end
			-- Set Mission Issuer
			Oxy_nm_3:set_mission_issuer("YUKANNADOOZAT");
			-- Trigger mission
			Oxy_nm_3:set_should_whitelist(false)
		end
	end
end

----------------------
------save/load-------
----------------------

cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("OxyotlMissionProgressCounter", Oxyotl_Vortex.mission_counter, context)
		cm:save_named_value("OxyotlMission1complete", Oxyotl_Vortex.mission_chain[Oxyotl_Vortex.mission_chain_1].mission_complete, context)
		cm:save_named_value("OxyotlMission2complete", Oxyotl_Vortex.mission_chain[Oxyotl_Vortex.mission_chain_2].mission_complete, context)
		cm:save_named_value("OxyotlMission3complete", Oxyotl_Vortex.mission_chain[Oxyotl_Vortex.mission_chain_3].mission_complete, context)
	end
);

cm:add_loading_game_callback(
	function(context)
		Oxyotl_Vortex.mission_counter = cm:load_named_value("OxyotlMissionProgressCounter", Oxyotl_Vortex.mission_counter, context)
		Oxyotl_Vortex.mission_chain[Oxyotl_Vortex.mission_chain_1].mission_complete = cm:load_named_value("OxyotlMission1complete", false, context)
		Oxyotl_Vortex.mission_chain[Oxyotl_Vortex.mission_chain_2].mission_complete = cm:load_named_value("OxyotlMission2complete", false, context)
		Oxyotl_Vortex.mission_chain[Oxyotl_Vortex.mission_chain_3].mission_complete = cm:load_named_value("OxyotlMission3complete", false, context)
	end
);
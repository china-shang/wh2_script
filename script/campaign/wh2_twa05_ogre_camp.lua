-- Handles the spawning, despawning, and interactions with the Ogre Camps.
-- HOW TO GET CAMPS TO SPAWN ALL THE TIME FOR DEBUGGING:
-- Set 'always_spawn_camp' to true. Better to do this before launching the campaign, otherwise the cooldowns and turns_until_active might prevent the camps from spawning anyway.
-- You can, however, set this to true at runtime, using the lua debug console (Ctrl + F3) and entering 'Ogre_Camp.always_spawn_camp = true'
-- After this, raiding and going to the next turn, or fighting a battle, should ALWAYS spawn an Ogre Camp (if one isn't spawning, either your cooldowns are active or it's a bug).
Ogre_Camp = {
	display_debug = false,
	always_spawn_camp = false,	-- Overrides cooldowns, turns_until_active, etc. for players. Basically ensures a camp will ALWAYS spawn each turn a player triggers a condition.
	cooldown = 20,
	marker_key = "ogre_camp",
	camp_spawn_distance = 15,
	turns_until_active = 10, -- The earliest turn at which Ogre Camps are able to spawn at all.
	incidents_to_spawn_chance = {
		raiding = 10,
		post_battle = 10,
		settlement_occupation = 20
	},
	ai_spawn_chance_modifier = 0.5,	-- AI spawn chance is multiplied by this quantity.

	-- All units that can be recruited from Ogre Camp dilemmas.
	ogre_units = {
		wh2_twa05_ogr_inf_ogres_0 = true,
		wh2_twa05_ogr_inf_ogres_1 = true,
		wh2_twa05_ogr_inf_maneaters_2 = true,
		wh2_twa05_ogr_inf_maneaters_3 = true,
		wh2_twa05_ogr_cav_mournfang_cavalry_0 = true,
	},

	-- The Ogre unit sets that an AI can receive. These should match the payloads that players get from the 'Visit Ogre Camp' dilemma,
	-- so ensure that they stay up to date with the cdir_events_dilemma_payloads table.
	ogre_ai_dilemma_payloads = {
		-- Headeaters
		{
			{ unit_key = "wh2_twa05_ogr_inf_ogres_1", amount = 2 },
			{ unit_key = "wh2_twa05_ogr_inf_maneaters_2", amount = 1 },
		},
		-- Deathbelchers
		{ 
			{ unit_key = "wh2_twa05_ogr_inf_ogres_0", amount = 2 },
			{ unit_key = "wh2_twa05_ogr_inf_maneaters_3", amount = 1 },
		},
		-- Horned Guts
		{ 
			{ unit_key = "wh2_twa05_ogr_cav_mournfang_cavalry_0", amount = 2 },
		},
	},

	-- Any stances which may be considered 'raiding', and therefore might trigger the arrival of Ogre Mercs.
	raiding_stances = {
		MILITARY_FORCE_ACTIVE_STANCE_TYPE_SET_CAMP_RAIDING = true,
		MILITARY_FORCE_ACTIVE_STANCE_TYPE_LAND_RAID = true,
	},

	ogre_merc_owners = {},	-- Any factions that have taken Ogre Mercs into their RoR pool (not necessarily hired yet) will be tracked in here.
	ogre_camp_cooldowns = {},	-- For each faction that an Ogre Camp has spawned, there is a timer that ticks down until it can spawn again for that faction.
	coundown_complete_for_turn = 0,	-- Nasty little hack I have to use because we have no event for 'only do this thing once per round'. Prevents the cooldown timer decreasing multiple times per round.

	bankruptcy_warning_turns = 1,
	bankruptcy_mutiny_turns = 3,

	incident_key = "wh2_twa05_ogre_camp_arrives",
	dilemma_key = "wh2_twa05_ogre_camp_negotiation",
	dilemma_hire_choices = {0, 1, 2},	-- All ogre-camp dilemma choices which represent hiring the ogres (i.e., excluding the one to just 'leave the camp').
	dilemma_hire_choices_set = {},	-- Handy for instant-checking of which dilemma choice was selected. Constructed using the standard list.

	-- The mutiny incidents are fired manually. Unlike the spawn/despawn events, they DO need to be defined in the database explicitly.
	mutiny_warning_incident = "wh2_twa05_ogre_mutiny_warning",
	mutiny_incident = "wh2_twa05_ogre_mutiny",

	-- The DLC key needed to enable Ogre Mercs. All players require the DLC to enable Ogre Camps.
	dlc_key = "TW_WH_TWA_05_OGRE_MERCS",
	dlc_key_enabled_message = "OgreMercsDLCEnabled",
	players_registered = 0,
	all_have_dlc = true,
	ownership_listener_name = "OgreCamp_DLCOwnershipListener",
}

for d = 1, #Ogre_Camp.dilemma_hire_choices do
	Ogre_Camp.dilemma_hire_choices_set[Ogre_Camp.dilemma_hire_choices[d]] = true
end

------------------------------------
---PER-FACTION OGRE_CAMP TRACKING---
------------------------------------

-- Merc Owner objects are used to track which factions own ogre mercs, and which are approaching bankruptcy.
Ogre_Merc_Owner = {}
Ogre_Merc_Owner.__index = Ogre_Merc_Owner

function Ogre_Merc_Owner:new(faction)
	local new_owner = {
		faction = faction,
		turns_bankrupt = 0,
		listeners = {},
	}

	self:new_from_table(new_owner)

	return new_owner
end

-- Gets a version of this table with only the data that needs to go into a savegame.
function Ogre_Merc_Owner:get_savable()
	local savable = {
		faction = self.faction,
		turns_bankrupt = self.turns_bankrupt,
	}
	return savable
end

function Ogre_Merc_Owner:new_from_table(table)
	-- Re-create non-saved table elements.
	table.listeners = {}
	
	setmetatable(table, self)
	table:setup_listeners()
	return table
end

function Ogre_Merc_Owner:setup_listeners()
	local bankruptcy_listener = self.faction .. "_OgreCamp_Bankruptcy"
	table.insert(self.listeners, bankruptcy_warning)

	core:add_listener(
		bankruptcy_listener,
		"ScriptEventHumanFactionTurnStart",
		true,
		function(context)
			local faction = cm:get_faction(self.faction)

			if faction:treasury() <= 0 then
				self.turns_bankrupt = self.turns_bankrupt + 1
			else
				self.turns_bankrupt = 0
			end
			
			if self.turns_bankrupt == Ogre_Camp.bankruptcy_warning_turns then
				if Ogre_Camp:faction_has_ogre_units(self.faction) then
					cm:trigger_incident(self.faction, Ogre_Camp.mutiny_warning_incident, true, true)
				end
			end

			if self.turns_bankrupt == Ogre_Camp.bankruptcy_mutiny_turns then
				-- Only give the player notice if they actually had any ogres employed.
				if Ogre_Camp:faction_has_ogre_units(self.faction, true) then
					cm:trigger_incident(self.faction, Ogre_Camp.mutiny_incident, true, true)
				end

				if Ogre_Camp.ogre_merc_owners[self.faction] then
					Ogre_Camp.ogre_merc_owners[self.faction] = nil
				else
					script_error("ERROR: An ogre_merc_owner table tried to remove itself from the list, but it was not present in the list."
						.. " This table should not exist without being an element of the ogre_merc_owners list. Ensure all new owner tables are added to this list, and removed when they're destroyed.")
				end
			end
		end,
		true
	)
end

function Ogre_Merc_Owner:remove()
	out("Removing faction '" .. self.faction .. "' as an ogre mercenary owner.")
	Ogre_Camp[self.faction] = nil
	for l = 1, #self.listeners do
		core:remove_listener(self.listeners[l])
	end
end

-------------------------
---OGRE CAMP FUNCTIONS---
-------------------------

-- Wait for the first tick to do the broadcast. This ensures that all other players should have their listeners ready.
core:add_listener(
	"OgreCamp_FirstTickAfterWorldCreated",
	"FirstTickAfterWorldCreated",
	true,
	function(context)
		CampaignUI.TriggerCampaignScriptEvent(cm:is_dlc_flag_enabled(Ogre_Camp.dlc_key) and 1 or 0, Ogre_Camp.dlc_key_enabled_message)
	end,
	false
)

function Ogre_Camp:setup()
	-- Check consistency between ogre_units set and ogre_ai_dilemma_payloads.
	for p = 1, #self.ogre_ai_dilemma_payloads do
		local payload = self.ogre_ai_dilemma_payloads[p]
		for u = 1, #payload do
			if not self.ogre_units[payload[u].unit_key] then
				script_error(string.format("WARNING: unit %s is available as an AI payload for receiving Ogre Mercenary units, yet this unit has not been defined as an ogre_unit in the script. This could cause inconsistent AI vs player Ogre Merc recruitment.", payload[u].unit_key))
			end
		end
	end

	-- First begin listening for other clients to send their message of ownership, and then broadcast your own message of ownership.
	core:add_listener(
		Ogre_Camp.ownership_listener_name,
		"UITrigger",
		function(context)
			return context:trigger() == Ogre_Camp.dlc_key_enabled_message
		end,
		function(context)
			-- Using the 'faction_cqi' as a true-false flag. That's a paddlin'.
			Ogre_Camp:register_dlc_ownership(context:faction_cqi() == 1)
		end,
		true
	)
end

-- Receive a message from either this client or another client saying whether or not the respective player owns the Ogre Camp DLC key.
-- Once all player messages have been received, if all of them own the key, then enable the camps.
function Ogre_Camp:register_dlc_ownership(owns_dlc)
	local number_of_players = #cm:get_human_factions()

	if not owns_dlc then
		self.all_have_dlc = false
	end

	self.players_registered = self.players_registered + 1

	if self.display_debug then
		out(string.format("Message received: Player owns Ogre Camp DLC?: %s. Quantity of clients that have broadcast their ownership status: %s / %s",
			tostring(owns_dlc), self.players_registered, number_of_players))
	end

	-- Wait for all clients to have reported their ownership before deciding to initialise ogres.
	if self.players_registered == number_of_players then
		out(string.format("All player ownership statuses received. All players own the Ogre Camp DLC?: %s. %s Ogre Camps.",
			tostring(self.all_have_dlc), self.all_have_dlc and "Enabling" or "Disabling"))
		
		if self.all_have_dlc then
			self:enable_ogres()
		end

		core:remove_listener(self.ownership_listener_name)
	end
end

-- Either enables ogre camps to spawn immediaetely, or sets a listener to wait for the required turn to enable them.
function Ogre_Camp:enable_ogres()
	if cm:is_new_game() then
		Ogre_Camp.marker = Interactive_Marker_Manager:new_marker_type(Ogre_Camp.marker_key, Ogre_Camp.marker_key, 10, nil, nil, nil, true)
		Ogre_Camp.marker:add_dilemma("wh2_twa05_ogre_camp_negotiation", false)
		-- Spawn/Despawn events rely on event_feed_message_event records which are bound to campaign groups (hence the numeric codes). These events do not need to be defined explicitly in the database as incidents.
		Ogre_Camp.marker:add_spawn_event_feed_event(
			"event_feed_strings_text_wh2_twa05_event_feed_string_scripted_event_ogres_arrive_title",
			"event_feed_strings_text_wh2_twa05_event_feed_string_scripted_event_ogres_arrive_primary_detail",
			"event_feed_strings_text_wh2_twa05_event_feed_string_scripted_event_ogres_arrive_secondary_detail",
			1710)
		Ogre_Camp.marker:add_despawn_event_feed_event(
			"event_feed_strings_text_wh2_twa05_event_feed_string_scripted_event_ogres_depart_title",
			"event_feed_strings_text_wh2_twa05_event_feed_string_scripted_event_ogres_depart_primary_detail",
			"event_feed_strings_text_wh2_twa05_event_feed_string_scripted_event_ogres_depart_secondary_detail",
			1711)
		Ogre_Camp.marker:despawn_on_interaction(true, Ogre_Camp.dilemma_hire_choices)
	end

	-- Wait for the minimum activation turn before initialising listeners.
	if cm:turn_number() >= self.turns_until_active or self.always_spawn_camp then
		if self.display_debug then
			out(string.format("Enough turns (%s) have passed to allow Ogre Camps. Setting up listeners.", self.turns_until_active))
		end
		self:setup_ogre_camp_listeners()
	else
		if self.display_debug then
			out(string.format("Waiting %s turns before allowing Ogre Camps to spawn.", self.turns_until_active))
		end

		core:add_listener(
		"OgreCamp_Startup",
		"FactionRoundStart",
		function(context)
			return cm:turn_number() >= self.turns_until_active
		end,
		function(context)
			if self.display_debug then
				out(string.format("Enough turns (%s) have passed to allow Ogre Camps. Setting up listeners.", self.turns_until_active))
			end
			self:setup_ogre_camp_listeners()
		end)
	end
end

-- Invoke this to test spawning Ogre Camps on all regions in the campaign. Useful for identifying sticky regions or a faulty spawning method.
function Ogre_Camp:test_spawns()
	local region_list = cm:model():world():region_manager():region_list()
	local player_faction_key = cm:get_human_factions()[1]

	out("Testing Ogre Camp spawn reliability ...")
	local all_successful = true

	for r = 0, region_list:num_items() - 1 do
		local region_key = region_list:item_at(r):name()
		local failures = 0
		for i = 1, 5 do
			local x, y = cm:find_valid_spawn_location_for_character_from_settlement(player_faction_key, region_key, false, false, self.camp_spawn_distance)
			if x == -1 then
				failures = failures + 1
			end
		end

		if failures > 0 then
			out(string.format("Attempt to find Ogre Camp spawning position for region %s using faction %s failed: %s / 5 times.", region_key, player_faction_key, failures))
			all_successful = false
		end
	end

	if all_successful then
		out("All regions were able to find an Ogre Camp spawn location every time!")
	end
end

---LISTENER SETUP---
function Ogre_Camp:setup_ogre_camp_listeners()
	-- Listens for human or AI players completing a battle, potentially spawning an Ogre Camp.
	core:add_listener(
		"OgreCamp_CompletedLandBattle",
		"CharacterCompletedBattle",
		function(context)
			local character = context:character()
			-- This is to ensure that camps don't spawn at sea and is not a settlement battle.
			return not character:is_null_interface() and not character:is_at_sea()
				and not context:pending_battle():has_contested_garrison()
		end,

		function(context)
			self:generate_ogre_camp_arrives_incident("post_battle", context:character():faction(), context:character():region():name())
		end,
		true
	)

	-- Handle settlement battles by waiting for the general to leave the settlement's ZoC. This prevents the pathfinding being unable to
	-- find a spot for the camp to spawn within.
	core:add_listener(
		"OgreCamp_CompletedSettlementBattle",
		"CharacterPerformsSettlementOccupationDecision",
		true,

		function(context)
			-- If a human faction is attacking or defending in a settlement battle, they have a chance of getting an ogre camp.
			local sieging_character = context:character()
			local sieging_faction = sieging_character:faction()
			local defending_faction = context:garrison_residence():faction()

			local faction_getting_ogre_camp = nil

			-- Generally give the ogre camp to the defender, unless the attacker is human. If both are human, favour the defender.
			if sieging_faction:is_human() then
				faction_getting_ogre_camp = defending_faction:is_human() and defending_faction or sieging_faction
			else
				faction_getting_ogre_camp = defending_faction
			end

			if faction_getting_ogre_camp then
				self:generate_ogre_camp_arrives_incident("settlement_occupation", faction_getting_ogre_camp, sieging_character:region():name())
			end
		end,
		true
	)
	
	-- Listens for human or AI players having raided in the last turn, potentially spawning an Ogre Camp.
	core:add_listener(
		"OgreCamp_TurnStart",
		"CharacterTurnStart",
		function(context)
			return self:character_is_raiding(context:character())
		end,

		function(context)
			self:generate_ogre_camp_arrives_incident("raiding", context:character():faction(), context:character():region():name())
		end,
		true
	)
	
	-- Reduces each Ogre Camp cooldown timer once per turn cycle.
	core:add_listener(
		"OgreCamp_Cooldown",
		"FactionRoundStart",
		true,
		function(context)
			-- Prevent FactionRoundStart from firing once for every faction in the game. Instead, fire it once per round.
			if self.coundown_complete_for_turn == cm:model():turn_number() then
				return
			else
				self.coundown_complete_for_turn = cm:model():turn_number()
			end

			local complete_cooldowns = {}

			for faction, _ in pairs(self.ogre_camp_cooldowns) do
				self.ogre_camp_cooldowns[faction] = self.ogre_camp_cooldowns[faction] - 1
				if self.ogre_camp_cooldowns[faction] <= 0 then
					table.insert(complete_cooldowns, faction)
				end
			end

			-- Clear all cooldowns that have reached zero.
			for f = 1, #complete_cooldowns do
				self.ogre_camp_cooldowns[complete_cooldowns[f]] = nil
			end
		end,
		true
	)

	-- Listens for a player actually purchasing some ogre units (after which we can respond to them going bankrupt).
	core:add_listener(
		"OgreCamp_OgresRecruited",
		"UnitTrained",
		function(context)
			local unit = context:unit()
			return unit:faction():is_human() and self.ogre_units[unit:unit_key()]
		end,
		function(context)
			local faction_key = context:unit():faction():name()
			if not self.ogre_merc_owners[faction_key] then
				self.ogre_merc_owners[faction_key] = Ogre_Merc_Owner:new(faction_key)
			end
		end,
		true
	)
end

-- Check if the faction has any ogres in its armies, and (if specified) remove them.
function Ogre_Camp:faction_has_ogre_units(faction_key, opt_remove_units)
	opt_remove_units = opt_remove_units or false

	local faction = cm:get_faction(faction_key)

	local faction_armies = faction:military_force_list();
	local ogres_found = false

	for i = 0, faction_armies:num_items() - 1 do
		local army = faction_armies:item_at(i)
		local ogre_unit_quantities = self:find_unit_quantities(self.ogre_units, army)
		
		if ogre_unit_quantities then
			ogres_found = true

			if opt_remove_units then
				local general_character = army:general_character()
				if general_character:is_null_interface() then
					script_error("ERROR: No character general found in army of faction '" .. faction_key
						.. "'. A character is needed in order to remove all Ogre units from this faction's armies. Army details:\n" .. cm:campaign_obj_to_string(army))
				else
					for i, value in ipairs(ogre_unit_quantities) do
						for u = 1, value.quantity do
							cm:remove_unit_from_character(cm:char_lookup_str(general_character), value.unit_key)
						end
					end
				end
			end
		end
	end

	return ogres_found
end

-- Get the quantities of all specified unit keys in this military force.
-- Results are returned in a list of tables with the format { unit_key = "dwarf_warriors_0", quantity = 5 }, or nil if no units were found.
function Ogre_Camp:find_unit_quantities(unit_keys, military_force)
	for k, v in pairs(unit_keys) do
		if type(v) ~= "boolean" or v ~= true then
			script_error("ERROR: The 'unit_keys' parameter for find_units_of_type must be a set, such as '{unit_1 = true, unit_2 = true ...}");
			return
		end
	end

	local unit_list = military_force:unit_list()
	local unit_mappings = {}
	local unit_quantities = {}
	local units_found = false

	for i = 0, unit_list:num_items() - 1 do
		unit_key = unit_list:item_at(i):unit_key()
		if unit_keys[unit_key] then
			if not unit_mappings[unit_key] then
				-- Store the index that the unit's register can be found at in unit_quantities.
				table.insert(unit_quantities, { unit_key = unit_key, quantity = 0 })
				unit_mappings[unit_key] = #unit_quantities
			end
			-- Say we found an Ogre Maneater. unit_mappings tells us this quantity is stored at index 2. We increment the value at index 2 by 1.
			-- This is all to quickly return a table that can be numerically iterated over, for multiplayer-safety.
			local quantity_tracker = unit_quantities[unit_mappings[unit_key]]
			quantity_tracker.quantity = quantity_tracker.quantity + 1
			units_found = true
		end
	end

	if units_found then
		return unit_quantities
	else
		return nil
	end
end

---CORE FUNCTIONS---
function Ogre_Camp:character_is_raiding(character)
	if character:is_null_interface() then
		script_error("Function Ogre_Camp:character_is_raiding() called without valid character")
		return false

	elseif not character:has_military_force() then
		return false

	elseif self.raiding_stances[character:military_force():active_stance()] then
		return true

	else 
		return false

	end
end

function Ogre_Camp:generate_ogre_camp_arrives_incident(event_type, faction, region_key)
	if self.display_debug then
		out("generate_ogre_camp_incident called with event_type: "..tostring(event_type))
	end

	local faction_key = faction:name()
	local is_player = faction:is_human()
	local always_spawn_for_player = is_player and self.always_spawn_camp

	if not self.ogre_camp_cooldowns[faction_key] or always_spawn_for_player then
		local spawn_chance = self.incidents_to_spawn_chance[event_type]

		-- Modify spawn chances based on AI or race-specific factors.
		if not faction:is_human() then
			spawn_chance = spawn_chance * self.ai_spawn_chance_modifier
		end
		
		if spawn_chance == nil then
			if self.display_debug then
				out("Ogre Camp incident check has been undertaken with an invalid event type " ..tostring(event_type))
			end
			return
		end

		local base_roll = cm:random_number(100, 1)
		local generate_ogre_camp_incident = base_roll <= spawn_chance or always_spawn_for_player
		if self.display_debug then
			out("Base roll is "..tostring(base_roll))
			out("Spawn chance is "..tostring(spawn_chance))
		end

		if generate_ogre_camp_incident then
			local success = false

			-- For players, we spawn an actual camp on the map. For AI, we just gift a random ogre payload.
			if is_player then
				success = not (Ogre_Camp.marker:spawn_at_region(region_key, false, false, false, self.camp_spawn_distance, faction_key) == false)
			else
				success = not (self:give_faction_ogre_mercs(faction) == false)
			end

			if not success then
				if is_player then
					script_error(string.format("ERROR: Failed to spawn Ogre Camp at region %s using pathfinding for faction %s as a result of event type %s.",
					region_key, faction_key, event_type))
				else
					script_error(string.format("ERROR: Failed to give Ogre Mercenaries to faction %s.", faction_key))
				end
			else
				self.ogre_camp_cooldowns[faction_key] = self.cooldown
				if self.display_debug then
					out(string.format("Ogre camp spawned at region %s using pathfinding for faction %s as a result of event type %s.", region_key, faction_key, event_type))
				end
			end
		end
	end
end

function Ogre_Camp:give_faction_ogre_mercs(faction)
	local random_index = cm:random_number(#self.ogre_ai_dilemma_payloads, 1)
	local payload = self.ogre_ai_dilemma_payloads[random_index]
	if self.display_debug then
		out(string.format("Giving mercenary payload #%s to faction %s", random_index, faction:name()))
	end

	for u = 1, #payload do
		cm:add_units_to_faction_mercenary_pool(faction:command_queue_index(), payload[u].unit_key, payload[u].amount)
	end
end

---SAVING AND LOADING---
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("ogre_camp_cooldowns", Ogre_Camp.ogre_camp_cooldowns, context)
		-- Need to get the savable copy of the merc owners objects to avoid saving things like listener keys.
		local savable_merc_owners = {}
		for key, value in pairs(Ogre_Camp.ogre_merc_owners) do
			savable_merc_owners[key] = value:get_savable()
		end
		cm:save_named_value("ogre_merc_owners", savable_merc_owners, context)
	end
);

cm:add_loading_game_callback(
	function(context)
		Ogre_Camp.ogre_camp_cooldowns = cm:load_named_value("ogre_camp_cooldowns", {}, context)
		Ogre_Camp.ogre_merc_owners = cm:load_named_value("ogre_merc_owners", {}, context)
		for key, value in pairs(Ogre_Camp.ogre_merc_owners) do
			Ogre_Camp.ogre_merc_owners[key] = Ogre_Merc_Owner:new_from_table(value)
		end
		if (not cm:is_new_game()) and (not Interactive_Marker_Manager.marker_list[Ogre_Camp.marker_key]) then
			script_error(string.format("ERROR: This is not a new game, yet there is no '%s' marker in the Marker Manager. Has this script deserialised before Marker Manager? Ogre Camps will be broken in your loaded game.",
				Ogre_Camp.marker_key))
		else
			Ogre_Camp.marker = Interactive_Marker_Manager.marker_list[Ogre_Camp.marker_key]
		end
	end
);
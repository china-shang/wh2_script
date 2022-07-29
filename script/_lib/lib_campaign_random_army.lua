----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	Random Army Manager
--
---	@loaded_in_campaign
---	@class random_army_manager random_army_manager Random Army Manager
--- @desc Used to create and manage multiple random or semi-random army templates that can be generated at any time throughout the campaign.
--- @desc Example Usage:
--- @desc 1) Create an army template
--- @desc <code>random_army_manager:new_force("my_template");</code>
--- @desc 2) Add 4 units to this army that will always be used when generating this template
--- @desc <code>random_army_manager:add_mandatory_unit("my_template", "unit_key1", 4);</code>
--- @desc 3) Add units to the template that can be randomly generated, with their weighting (that is their chance of being picked, this is not how many will be picked)
--- @desc <code>random_army_manager:add_unit("my_template", "unit_key1", 1);</code>
--- @desc <code>random_army_manager:add_unit("my_template", "unit_key2", 1);</code>
--- @desc <code>random_army_manager:add_unit("my_template", "unit_key3", 2);</code>
--- @desc 4) Generate a random army of 6 units from this template
--- @desc <code>local force = ram:generate_force("my_template", 6, false);</code>
--- @desc <code>Output: "unit_key1,unit_key1,unit_key1,unit_key1,unit_key2,unit_key3"</code>


---------------------
---- Definitions ----
---------------------
random_army_manager = {
	force_list = {}
};

function random_army_manager:__tostring()
	return TYPE_RANDOM_ARMY_MANAGER;
end

function random_army_manager:__type()
	return TYPE_RANDOM_ARMY_MANAGER;
end


-------------------------------------------------------------------------------------------
--- @section Random Army Manager Functions
--- @desc Functions relating to the Manager and its control over the various defined forces
-------------------------------------------------------------------------------------------

--- @function new_force
--- @desc Adds a new force to the random army manager
--- @p string force key, a unique key for this new force
--- @return boolean Returns true if the force was created successfully
function random_army_manager:new_force(key)
	out.design("Random Army Manager: Creating New Force with key [" .. key .. "]");
	local force = {};

	for i = 1, #self.force_list do
		if key == self.force_list[i].key then
			self.force_list[i].key = key;
			self.force_list[i].units = {};
			self.force_list[i].mandatory_units = {};
			self.force_list[i].faction = "";
			out.design("\tForce with key [" .. key .. "] already exists - resetting force!");
			return true;
		end
	end

	force.key = key;
	force.units = {};
	force.mandatory_units = {};
	force.faction = "";
	table.insert(self.force_list, force);
	out.design("\tForce with key [" .. key .. "] created!");
	return true;
end

--- @function add_unit
--- @desc Adds a unit to a force, making it available for random selection if this force is generated. The weight value is an arbitrary figure that should be relative to other units in the force
--- @p string key of the force
--- @p string key of the unit
--- @p number weight value
function random_army_manager:add_unit(force_key, key, weight)
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			for j = 1, weight do
				table.insert(self.force_list[i].units, key);
				out.design("Random Army Manager: Adding Unit- [" .. key .. "] with weight: [" .. weight .. "] to force: [" .. force_key .. "]");
			end
			break;
		end
	end
end

--- @function add_mandatory_unit
--- @desc Adds a mandatory unit to a force composition, making it so that if this force is generated this unit will always be part of it
--- @p string key of the force
--- @p string key of the unit
--- @p number amount of these units
function random_army_manager:add_mandatory_unit(force_key, key, amount)
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			for j = 1, amount do
				table.insert(self.force_list[i].mandatory_units, key);
				out.design("Random Army Manager: Adding Mandatory Unit- [" .. key .. "] with amount: [" .. amount .. "] to force: [" .. force_key .. "]");
			end
			break;
		end
	end
end

--- @function set_faction
--- @desc Sets the faction key associated with this force - Allows you to store the faction key used to spawn the army from the force
--- @p string key of the force
--- @p string key of the faction
function random_army_manager:set_faction(force_key, faction_key)
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			self.force_list[i].faction = faction_key;
			break;
		end
	end
end

--- @function generate_force
--- @desc This generates a force randomly, first taking into account the mandatory unit and then making random selection of units based on weighting. Returns an array of unit keys or a comma separated string for use in the create_force function if the last boolean value is passed as true
--- @p string key of the force
--- @p number amount of units
--- @p boolean pass true to return the force as a table, false to get a comma separated string
--- @return object Either a table containing the unit keys, or a comma separated string of units
function random_army_manager:generate_force(force_key, unit_count, return_as_table)
	local force = {};
	local faction = "";
	
	if is_table(unit_count) then
		unit_count = cm:random_number(math.max(unit_count[1], unit_count[2]), math.min(unit_count[1], unit_count[2]));
	end;
	
	unit_count = math.min(19, unit_count);
	
	out.design("Random Army Manager: Getting Random Force for army [" .. force_key .. "] with size [" .. unit_count .. "]");
	
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then			
			local mandatory_units_added = 0;
			
			for j = 1, #self.force_list[i].mandatory_units do
				table.insert(force, self.force_list[i].mandatory_units[j]);
				mandatory_units_added = mandatory_units_added + 1;
			end
			
			for k = 1, unit_count - mandatory_units_added do
				local unit_index = cm:random_number(#self.force_list[i].units);
				table.insert(force, self.force_list[i].units[unit_index]);
			end

			faction = self.force_list[i].faction;
			break;
		end
	end
	
	if #force == 0 then
		script_error("Random Army Manager: Did not add any units to force with force_key [" .. force_key .. "] - was the force created?");
		return false;
	elseif return_as_table then
		return force, faction;
	else
		return table.concat(force, ","), faction;
	end
end

--- @function remove_force
--- @desc Remove an existing force from the force list
--- @p string key of the force
function random_army_manager:remove_force(force_key)
	out.design("Random Army Manager: Removing Force with key [" .. force_key .. "]");
	
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			table.remove(self.force_list, i);
			break;
		end
	end
end

--- @function mandatory_unit_count
--- @desc Returns the amount of mandatory units specified in this force
--- @p string key of the force
function random_army_manager:mandatory_unit_count(force_key)
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			return #self.force_list[i].mandatory_units;
		end
	end
	return -1;
end
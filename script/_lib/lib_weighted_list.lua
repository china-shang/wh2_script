----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	WEIGHTED_LIST
--
---	@loaded_in_campaign
---	@class weighted_list weighted_list Weighted List
--- @desc A weighted list is an expanded table object allowing for semi-random selection of items from the table based on their preset weighting set when adding the item

--- @section Example Usage
--- @new_example Creating, Inserting and Extracting
--- @desc The following creates a new weighted list, adds some items to it, and then retrieves a semi-random item from the list taking into account the weighting of the objects
--- @example local new_list = weighted_list:new();
--- @example new_list:add_item("Bob", 5);
--- @example new_list:add_item("John", 5);
--- @example new_list:add_item("Steve", 10);
--- @example  
--- @example local result = new_list:weighted_select();
--- @example  
--- @example -- Effective chance of each item being selected: Bob 25%, John 25%, Steve 50%

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
weighted_list = {};

function weighted_list:__tostring()
	return TYPE_WEIGHTED_LIST;
end

function weighted_list:__type()
	return TYPE_WEIGHTED_LIST;
end

--- @section Creation
--- @function new
--- @desc Creates a new weighted list object
--- @p [opt=nil] table o, Pass an object to the new function to use that instance of the object as this new one
--- @return weighted_list the new weighted list object
function weighted_list:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	o.items = {};
	o.max_weight = 0;
	return o;
end

--- @section Adding & Removing
--- @function add_item
--- @desc Allows adding of new items to the weighted list with a set weighting
--- @p object item, The item to add to the list
--- @p number weight, The weight of this item
function weighted_list:add_item(item, weight)
	if weight > 0 then
		local list_entry = {};
		list_entry.item = item;
		list_entry.weight = math.ceil(weight);
		table.insert(self.items, list_entry);
		self.max_weight = self.max_weight + weight;
	end
end

--- @function remove_item
--- @desc Allows removal of an item from the weighted list
--- @p number i, The index of the item to remove
function weighted_list:remove_item(i)
	self.max_weight = self.max_weight - self.items[i].weight;
	table.remove(self.items, i);
end

--- @section Selection
--- @function weighted_select
--- @desc Selects an item from the weighted list with the chance of each item
--- @desc being selected being their weight relative to all other items
--- @return object the selected item
function weighted_list:weighted_select()
	local rand = cm:random_number(self.max_weight);

	for i = 1, #self.items do
		rand = rand - self.items[i].weight;

		if rand <= 0 then
			return self.items[i].item, i, self.items[i].weight;
		end
	end
end

--- @function random_select
--- @desc Randomly selects an item from the weighted list disregarding any weighting
--- @return object the selected item
function weighted_list:random_select()
	local rand = cm:random_number(#self.items);
	return self.items[rand].item, rand, self.items[rand].weight;
end
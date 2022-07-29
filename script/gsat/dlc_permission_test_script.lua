require "data.script.gsat.lib.all"


----------------------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------------------

function dlc_message()
	callback(function()
		local component = Functions.find_component("popup_new_content:button_close")
		if (component ~= nil) then
			component:SimulateLClick()
		end
	end)
end

function list_lords(campaign)
	callback(function()
		local lords_list = Functions.find_component('lord_select_list:list_clip:list_box')
		local lords_file = io.open('lords_' .. campaign .. '.txt', 'w')
		if lords_list ~= nil then
			Utilities.print('Lord list box found')
			local lords = Functions.get_all_children_from_parent(lords_list)
			for k, v in pairs(lords) do
				if v:Visible()
				then
					Utilities.print('Found Lord - ' .. v:Id())
					Utilities.print('Lord Name - ' .. v:GetProperty('lord_key'))
					Utilities.print('Tool Tip - ' .. v:GetTooltipText())
					Utilities.print('StateText - ' .. v:GetStateText())

					lords_file:write(v:Id(), '\n')
				end
			end
		else
			Utilities.print('List box Not Found!!')
		end

		lords_file:close()
	end)
end

function get_campaign_load_lords_list(campaign_name)
	callback(function()
		local campaign_select_name
		if campaign_name == 'eye_of_the_vortex'
		then
			campaign_select_name = Functions.find_component('wh2_main_great_vortex:button_campaign_entry')
		else
			campaign_select_name = Functions.find_component('main_warhammer:button_campaign_entry')
		end

		-- Click on campaign
		Common_Actions.click_component(campaign_select_name, nil, true)

		callback(function()
			-- Check if the button_next is visible (that would mean that it's enabled for this DLC combination)
			local button_next_component = Functions.find_component('button_next')
			if button_next_component ~= nil and button_next_component:Visible() == true then
				Utilities.print('button_next found')

				Common_Actions.click_component(Functions.find_component('button_next'), nil, true)

				list_lords(campaign_name)

				-- Go back to campaign selection menu
				Lib.Frontend.Clicks.return_home()
			else
				Utilities.print('button_next not found')
			end
		end)
	end)
end

function list_units(faction_name)
	callback(function()
		local units_path = 'listview_army:list_clip:list_box'

		local component = Functions.find_component(units_path)
		if component ~= nil then
			-- Find all the child components
			local unit_categories = Functions.get_all_children_from_parent(component)
			for k, v in pairs(unit_categories)
			do
				local category = v:Id()
				local unit_category_full_path = units_path .. ':' .. category .. ':' .. 'units_box'
				local units_component = Functions.find_component(unit_category_full_path)

				local file_handle = io.open('battle_units_' .. faction_name .. '.txt', 'a')
				file_handle:write('-- ' .. category, '\n')

				local unit = Functions.get_all_children_from_parent(units_component)
				for k, v in pairs(unit)
				do
					local tool_tip = v:GetTooltipText()
					local new_line = tool_tip:find('\n')
					if new_line ~= nil then
						tool_tip = tool_tip:sub(1, new_line - 1)
					end
					local delimited = tool_tip:find('|')
					if delimited ~= nil then
						tool_tip = tool_tip:sub(1, delimited - 1)
					end
					file_handle:write(tool_tip, '\n')
				end

				file_handle:write('\n')
				file_handle:close()
			end
		end
	end)
end

function get_battle_faction(faction_button)
	callback(function()
		local faction_selection = 'setup_faction_menu:faction_dropdown:popup_menu:popup_list'
		local faction_button_path = faction_selection .. ':' .. faction_button
		local faction_row_tx_path = faction_button_path .. ':' .. 'row_tx'
		Utilities.print(faction_button_path)
		local faction_name = 'UNKNOWN'

		local row_tx_component = Functions.find_component(faction_row_tx_path)
		if row_tx_component == nil or row_tx_component:Visible() == false then
			return
		end

		faction_name = row_tx_component:GetStateText()

		local file_handle = io.open('battle_factions.txt', 'a')
		file_handle:write(faction_name, '\n')
		file_handle:close()

		Common_Actions.click_component(Functions.find_component("button_change_faction"), nil, true)
		Lib.Helpers.Misc.wait(0.5)
		callback(function()
			local comp = Functions.find_component(faction_button_path)
			Common_Actions.click_component(comp, faction_button_path, true)
			list_units(faction_name)
		end)
	
	end)
end

function get_battle_faction_list()
	callback(function()
		local factions_list = Functions.find_component('setup_faction_menu:faction_dropdown:popup_menu:popup_list')
		if factions_list ~= nil then
			Utilities.print('Faction list found')
			local factions = Functions.get_all_children_from_parent(factions_list)
			for k, v in pairs(factions)
			do
				get_battle_faction(v:Id())				
			end
		else
			Utilities.print('factions Not Found!!')
		end
	end)
end

function get_quest_battle_characters()
	callback(function()
		local lord_list = Functions.find_component('listview:list_clip:list_box')
		local lord_file = io.open("quest_lords.txt", "w")
		if lord_list ~= nil then
			Utilities.print('Lord list box found')
			local lords = Functions.get_all_children_from_parent(lord_list)
			for _, quest_root in pairs(lords) do
				if quest_root:Visible() == true then
					local quest_root_children = Functions.get_all_children_from_parent(quest_root)
					local lordname_component = Functions.find_component("dy_name", quest_root)
					if lordname_component ~= nil then
						Utilities.print("dy_name_found")
						lordname = (lordname_component:GetStateText())
						Utilities.print(lordname.."-available")
						lord_file:write(lordname,'\n')
					end
				end
			end
			lord_file:close()
		end
	end)
end

----------------------------------------------------------------------------------------------------------------
-- Action Sequence
----------------------------------------------------------------------------------------------------------------

Lib.Frontend.Misc.verify()

dlc_message()

-- Campaign
Lib.Frontend.Clicks.menu_campaign()
Lib.Frontend.Clicks.new_campaign()

-- Check for Vortex Campaign Lords
get_campaign_load_lords_list('eye_of_the_vortex')

-- Check for Mortal Empire Campaign lords
get_campaign_load_lords_list('mortal_empires')

-- Go back to Main Menu
Lib.Frontend.Clicks.return_home()

-- Battle
Lib.Frontend.Clicks.custom_battle()
--Common_Actions.click_component(Lib.Components.Frontend.open_faction(),'Open faction dropdown', true)

Lib.Helpers.Misc.wait(1.5)

get_battle_faction_list()

-- Go back to Main Menu
--Lib.Helpers.Misc.wait(10)
Lib.Frontend.Clicks.return_home()
Lib.Helpers.Misc.wait(1.5)
-- Quest Battles
Lib.Frontend.Clicks.quest_battle()

get_quest_battle_characters()

-- Quit
Lib.Frontend.Clicks.return_home()
Lib.Frontend.Clicks.quit_to_windows()
Lib.Frontend.Clicks.confirm_quit()

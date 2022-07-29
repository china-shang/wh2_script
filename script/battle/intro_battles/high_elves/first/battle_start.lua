load_script_libraries();
bm = battle_manager:new(empire_battle:new());

local file_name, file_path = get_file_name_and_path();

-- load the wh2 intro battle script library
package.path = "script/battle/intro_battles/?.lua"
require("wh2_intro_battle");

package.path = file_path .. "/?.lua;" .. package.path;

require("battle_declarations");
require("battle_cutscenes");
require("battle_main");

--电脑名称处理

local U = {}

local allowsHeroData = require(GetScriptDirectory() .. "/AuxiliaryScript/GameNameTable")
local dota2team = allowsHeroData.Name

function U.GetDota2Team()
	local bot_names = {};
	for i = 0,4 do
		table.insert(bot_names, U.RandName(bot_names));
	end
	return bot_names;
end

function U.RandName(botnames)
	local rand = RandomInt(1, #dota2team);
	if GetTeam() == TEAM_RADIANT then
		while rand%2 ~= 0 do
			rand = RandomInt(1, #dota2team); 
		end
	else
		while rand%2 ~= 1 do
			rand = RandomInt(1, #dota2team); 
		end
	end
	for i = 0, #botnames do
		if dota2team[rand] == botnames[i] then 
			return U.RandName(botnames)
		end
	end
	return dota2team[rand]
end
return U
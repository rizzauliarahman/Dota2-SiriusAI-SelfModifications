----------------------------------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI 
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local bot = GetBot()
local botName = bot:GetUnitName()

if bot:IsInvulnerable() 
	or not bot:IsHero() 
	or bot:IsIllusion()
	or not string.find( botName, "hero" )
	or botName == "npc_dota_hero_techies"
then
	return
end

local BotBuild = nil 
--local BotBuild = dofile(GetScriptDirectory() .. "/BotLib/" .. string.gsub(GetBot():GetUnitName(), "npc_dota_", ""));
xpcall(
	function(bot) 
		BotBuild = dofile( GetScriptDirectory().."/BotLib/"..string.gsub( GetBot():GetUnitName(), "npc_dota_", "" ) )
	end, 
	function(err) 
		if errc(err) then 
			local postData = {
				operation = 'ERROR',
				errorContent = err.string,
			}
			H.HttpPost(postData, 'api.alcedo.top:3010',function (x, t)end,'',true);
			print(err) 
		end 
	end)

if BotBuild == nil then return end

function MinionThink(hMinionUnit)

	BotBuild.MinionThink(hMinionUnit)
	
end
-- dota2jmz@163.com QQ:2462331592.
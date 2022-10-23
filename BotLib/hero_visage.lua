local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--编组技能、天赋、装备
local tGroupedDataList = {
	
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {0, 10},
		['t15'] = {10, 0},
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = {1,3,2,2,3,6,2,3,3,1,6,1,2,1,6},
	--装备
	['Buy'] = {
		"item_quelling_blade",
		"item_blades_of_attack",
		"item_tango",
		"item_blight_stone",
		"item_magic_wand",
		"item_boots",
		"item_medallion_of_courage",
		"item_tranquil_boots",
		"item_vladmir",
		"item_force_staff", 
		"item_pipe",
		"item_sheepstick",
		"item_ultimate_scepter",
		"item_lotus_orb",
		"item_ultimate_scepter2",
	},
	--出售
	['Sell'] = {
		"item_travel_boots",
		"item_tranquil_boots"
	},
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData, true)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	   and (
			hMinionUnit:GetUnitName() ~= "npc_dota_visage_familiar1" or
			hMinionUnit:GetUnitName() ~= "npc_dota_visage_familiar2" or
			hMinionUnit:GetUnitName() ~= "npc_dota_visage_familiar3" 
		)
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'Q','W','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end


return X
-- dota2jmz@163.com QQ:2462331592

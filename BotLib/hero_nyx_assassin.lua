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
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	['Ability'] = {1,3,1,3,1,6,1,2,3,2,6,2,2,2,6},
	['Buy'] = {
		"item_enchanted_mango",
		"item_enchanted_mango",
		"两个item_tango",
		"item_magic_wand",
		"item_arcane_boots",
		"item_force_staff",
		"item_blink",
		"item_aether_lens",
		"item_ultimate_scepter",
		"item_meteor_hammer",
		"item_sheepstick",
		"item_lotus_orb",
	},
	['Sell'] = {
		"item_travel_boots",
		"item_arcane_boots",

	}
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData, true)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit)
	then
		Minion.IllusionThink(hMinionUnit)	
	end

end

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() or bot:HasModifier("modifier_nyx_assassin_vendetta") then return end
	--技能检查顺序
	local order = {'Q','W','E','R','D'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
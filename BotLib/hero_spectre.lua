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
		['t20'] = {0, 10},
		['t15'] = {10, 0},
		['t10'] = {0, 10},
	},
	['Ability'] = {1,3,2,3,3,6,3,1,1,1,6,2,2,2,6},
	['Buy'] = {
		"item_quelling_blade",
		"item_tango",
		"item_magic_wand",
		"item_phase_boots",
		"item_vanguard",
		"item_blade_mail",
		"item_diffusal_blade",
		"分身斧",
		"item_black_king_bar",
		"item_radiance",
		"item_satanic",
		"item_butterfly",
	},
	['Sell'] = {
		"item_abyssal_blade",
		"item_quelling_blade",

	}
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData, true)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit)
	then
		Minion.IllusionThink(hMinionUnit)	
	end

end

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'D','Q','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
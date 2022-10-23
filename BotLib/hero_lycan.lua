local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--编组技能、天赋、装备
local tGroupedDataList = {}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {0, 10},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	['Ability'] = {3,1,3,1,1,6,1,2,3,2,6,2,3,2,6},
	['Buy'] = {
		"树之祭祀",
		"两个魔法芒果",
		"压制之刃",
		"枯萎之石",
		"护腕",
		"速度之靴",
		"回音战刃",
		"碎颅锤",
		"黑皇杖",
		"黯灭",
		"深渊之刃", 
		"强袭胸甲",
		"相位鞋",
	},
	['Sell'] = {}
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
	   and (
			hMinionUnit:GetUnitName() ~= "npc_dota_lycan_wolf1" or
			hMinionUnit:GetUnitName() ~= "npc_dota_lycan_wolf2" or
			hMinionUnit:GetUnitName() ~= "npc_dota_lycan_wolf3" or
			hMinionUnit:GetUnitName() ~= "npc_dota_lycan_wolf4" 
		)
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'R','Q','W','D'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
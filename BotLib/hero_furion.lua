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
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	['Ability'] = {3,2,3,1,3,6,3,1,2,2,6,2,1,1,6},
	['Buy'] = {
		"树之祭祀",
		"风灵之纹",
		"毛毛帽",
		"奥术鞋",
		"韧鼓",
		"阿托斯之棍",
		"阿哈利姆魔晶",
		"阿哈利姆神杖",
		"影刃", 
		"紫怨",
		"血棘",
		"邪恶镰刀",
		"达贡之神力5",
		"白银之锋",
	},
	['Sell'] = {
		"黑皇杖",
		"毛毛帽",

		"远行鞋",
		"相位鞋",
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
	   and (
			hMinionUnit:GetUnitName() ~= "npc_dota_furion_treant_large" or
			hMinionUnit:GetUnitName() ~= "npc_dota_furion_treant" 
		)
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'Q','W','E','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
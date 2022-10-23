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
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	['Ability'] = {1,2,2,1,2,6,1,1,2,4,6,4,4,4,6},
	['Buy'] = {
		"魔法芒果",
		"两个魔法芒果",
		"树之祭祀",
		"淬毒之珠",
		"护腕",
		"魔棒",
		"相位鞋",
		"影之灵龛",
		"阿托斯之棍",
		"死灵书",
		"阿哈利姆神杖",
		"碎颅锤",
		"邪恶镰刀",
		"深渊之刃"
	},
	['Sell'] = {
		"虚灵之刃",
		"淬毒之珠",
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
	   and (
			hMinionUnit:GetUnitName() ~= "npc_dota_beastmaster_boar_1" or
			hMinionUnit:GetUnitName() ~= "npc_dota_beastmaster_boar_2" or
			hMinionUnit:GetUnitName() ~= "npc_dota_beastmaster_boar_3" or
			hMinionUnit:GetUnitName() ~= "npc_dota_beastmaster_boar_4" 
		)
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

local hEnemyOnceLocation = {}

for _,TeamPlayer in pairs( GetTeamPlayers(GetOpposingTeam()) )
do
    hEnemyOnceLocation[TeamPlayer] = nil;
end

local hEnemyRecordLocation = {}

function X.SkillsComplement()
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'R','Q','W','E'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
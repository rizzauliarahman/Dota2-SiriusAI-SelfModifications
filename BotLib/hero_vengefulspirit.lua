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
		['t15'] = {10, 0},
		['t10'] = {0, 10},
	},
	['Ability'] = {1,2,1,3,1,6,1,3,3,3,6,2,2,2,6},
	['Buy'] = {
		'树之祭祀',
		'魔法芒果',
		'两个魔法芒果',
		'毛毛帽',
		'魔杖',
		'静谧之鞋',
		'韧鼓',
		'微光披风',
		'阿哈利姆魔晶',
		'原力法杖',
		'弗拉迪米尔的祭品',
		'黑皇杖',
		'黯灭',
		'阿哈利姆神杖',
		'永恒之盘',
		'飓风长戟',
		'阿哈利姆神杖2',
	},
	['Sell'] = {
		'白银之锋',
		'微光披风',

		'蝴蝶',
		'毛毛帽',

		'强袭胸甲',
		'韧鼓',
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
		if hMinionUnit:IsIllusion() 
		then 
			Minion.IllusionThink(hMinionUnit)	
		end
	end

end

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'R','Q','W'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
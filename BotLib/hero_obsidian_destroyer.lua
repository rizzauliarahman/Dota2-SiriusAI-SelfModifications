local X = {}
local bDebugMode = false;
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--编组技能、天赋、装备
local tGroupedDataList = {
	{
		['info'] = 'By Misunderstand',
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		['Ability'] = { 2, 3, 2, 1, 2, 6, 2, 3, 3, 1, 6, 1, 3, 1, 6 },
		['Buy'] = {
			"两个智力斗篷",
			"圆环",
			"树之祭祀",
			"魔棒",
			"两个空灵挂件",
			"治疗药膏",
			"动力鞋",
			"慧光",
			"闪烁匕首",
			"慧夜对剑",
			"黑皇杖",
			"邪恶镰刀",
			"刷新球",
			"飓风长戟",
			"阿哈利姆神杖2",
			"银月之晶",
		},
		['Sell'] = {
			"黑皇杖",
			"魔棒",
			
			"邪恶镰刀",
			"空灵挂件",
			
			"飓风长戟",
			"闪烁匕首",
		}
	}
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	['Ability'] = {2,3,1,3,3,6,3,2,1,2,6,2,1,1,6},
	['Buy'] = {
		"两个智力斗篷",
		"圆环",
		"树之祭祀",
		"魔棒",
		"两个空灵挂件",
		"治疗药膏",
		"动力鞋",
		"飓风长戟",
		"慧夜对剑",
		"黑皇杖",
		"希瓦的守护",
		"阿哈利姆神杖2",
		"邪恶镰刀",
	},
	['Sell'] = {
		"金箍棒",
		"奥术鞋",
		
		"Eul的神圣法杖",
		"魔杖",
	}
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
	then
		Minion.IllusionThink(hMinionUnit)	
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

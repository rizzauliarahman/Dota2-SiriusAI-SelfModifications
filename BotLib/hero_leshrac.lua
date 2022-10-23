local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--编组技能、天赋、装备
local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 1, 3, 2, 3, 2, 6, 2, 2, 3, 3, 6, 1, 1, 1, 6 },
		--装备
		['Buy'] = {
			"铁树枝干",
			"两个智力斗篷",
			"圆环",
			"树之祭祀",
			"两个魔法芒果",
			"魔杖",
			"两个空灵挂件",
			"速度之靴",
			"Eul的神圣法杖",
			"远行鞋", 
			"血精石",
			"黑皇杖", 
			"慧光",
			"希瓦的守护",
			"慧夜对剑",
			"阿哈利姆神杖2", 
			"远行鞋2",
			"玲珑心",
			"银月之晶",
		},
		--出售
		['Sell'] = {
			"血精石",
			"魔杖",

			"慧光",
			"空灵挂件",
					
			"玲珑心",   
			"慧夜对剑", 
		},
	}
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {0, 10},
	},
	['Ability'] = {1,2,2,3,2,6,2,3,3,3,1,1,1,6,6},
	['Buy'] = {
		'树之祭祀',
		'治疗药膏',
		'仙灵之火',
		'魔棒',
		'奥术鞋',
		'阿托斯之棍',
		'先锋盾',
		'微光披风',
		'慧夜对剑',
		'阿哈利姆神杖',
		'邪恶镰刀',
	},
	['Sell'] = {
		"幻影斧",
		"影之灵龛",

		"黑皇杖",
		"魔龙枪",
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

	J.ConsiderForMkbDisassembleMask(bot);
	J.ConsiderTarget();
	
	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'Q','W','E','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
-- dota2jmz@163.com QQ:2462331592

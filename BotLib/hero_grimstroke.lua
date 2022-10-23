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
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		['Ability'] = { 3, 1, 1, 2, 1, 3, 2, 2, 6, 1, 6, 3, 3, 2, 6 },
		['Buy'] = {
			"圆环",
				"树之祭祀",
				"净化药水",
				"魔法芒果",
				"治疗药膏",
				"魔棒",
				"凝魂之露",
				"树之祭祀",
				"净化药水",
				"魔法芒果",
				"影之灵龛", 
				"奥术鞋",
				"以太透镜",
				"微光披风",
				"阿哈利姆魔晶",
				"魂之灵瓮",
				"天堂之戟",
				"邪恶镰刀",
				"阿哈利姆神杖2",
				"远行鞋", 
				"虚灵之刃"
		},
		['Sell'] = {
			"远行鞋",     
			"奥术鞋", 
	
			"虚灵之刃",
			"微光披风" 
		}
	},
	{
		--组合说明，不影响游戏
		['info'] = '辅助',
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		['Ability'] = { 3,1,1,3,1,6,1,2,2,2,6,2,3,3,6 },
		['Buy'] = {
			"两个魔法芒果",
			"树之祭祀",
			"魔法芒果",
			"魔棒",
			"奥术鞋",
			"以太透镜",
			"微光披风",
			"阿哈利姆魔晶",
			"阿托斯之棍",
			"天堂之戟",
			"邪恶镰刀",
			"缚灵索",
			"阿哈利姆神杖2",
		},
		['Sell'] = {
			"远行鞋",     
			"奥术鞋", 
		}
	}

}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	['Ability'] = {3,1,1,2,1,6,1,3,3,3,6,2,2,2,6},
	['Buy'] = {
		"树之祭祀",
		"魔法芒果",
		"两个铁树枝干",
		"魔法芒果",
		"净化药水",
		"奥术鞋",
		"阿托斯之棍",
		"微光披风",
		"阿哈利姆神杖",
		"Eul的神圣法杖",
		"邪恶镰刀",
		"原力法杖",
		"血棘",
		"死灵书3",
	},
	['Sell'] = {
		"赤红甲",
		"压制之刃",
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
	local order = {'R','Q','W','D','F','E'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X

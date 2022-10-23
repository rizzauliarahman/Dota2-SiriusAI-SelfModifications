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
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		['Ability'] = { 3, 1, 3, 2, 3, 6, 2, 3, 2, 2, 6, 1, 1, 1, 6 },
		['Buy'] = {
			"树之祭祀",
			"力量手套",
			"两个铁树枝干",
			"魔杖",
			"护腕",
			"魔法芒果",
			"相位鞋",
			"先锋盾",
			"闪烁匕首",
			"挑战头巾",
			"阿哈利姆魔晶",
			"辉耀",
			"洞察烟斗",
			"赤红甲",
			"恐鳌之心",
			"盛势闪光",
			"阿哈利姆神杖2",
			"远行鞋",
			"银月之晶",
			"远行鞋2"
		},
		['Sell'] = {
			"挑战头巾",     
			"护腕",

			"恐鳌之心",     
			"魔杖",
					
			"远行鞋",
			"相位鞋"
		}
	},
	{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		['Ability'] = { 3, 2, 3, 1, 3, 6, 3, 2, 2, 2, 6, 1, 1, 1, 6},
		['Buy'] = {
			"树之祭祀",
			"治疗药膏",
			"两个魔法芒果",
			"力量手套",
			"魔棒",
			"护腕",
			"魔杖",
			"相位鞋",
			"先锋盾",
			"挑战头巾", 
			"闪烁匕首",
			"炎阳纹章",
			"阿哈利姆魔晶",
			"赤红甲",
			"阿哈利姆神杖",
			"洞察烟斗",
			"恐鳌之心",
			"盛势闪光",
			"阿哈利姆神杖2",
			"希瓦的守护",
			"远行鞋2",
			"银月之晶"
		},
		['Sell'] = {
			"赤红甲",
			"护腕",

			"阿哈利姆神杖",
			"魔棒",

			"阿哈利姆神杖",     
			"护腕",

			"远行鞋2",
			"相位鞋"
		}
	},
	{
		--组合说明，不影响游戏
		['info'] = 'Alcedo',
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		['Ability'] = { 3, 1, 3, 2, 3, 6, 3, 2, 2, 2, 6, 1, 1, 1, 6},
		['Buy'] = {
			"树之祭祀",
			"压制之刃",
			"两个魔法芒果",
			"力量手套",
			"魔棒",
			"护腕",
			"魔杖",
			"相位鞋",
			"先锋盾",
			"挑战头巾", 
			"恐鳌之戒",
			"碎颅锤",
			"恐鳌之心",
			"希瓦的守护",
			"阿哈利姆神杖",
			"深渊之刃",
			"阿哈利姆神杖2",
			"银月之晶"
		},
		['Sell'] = {
			"清莲宝珠",
			"护腕",

			"散夜对剑",
			"挑战头巾",

			"远行鞋2",
			"相位鞋"
		}
	},
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {0, 10},
	},
	['Ability'] = {2,3,1,2,2,6,2,3,3,3,6,1,1,1,6},
	['Buy'] = {
		"树之祭祀",
		"治疗药膏",
		"压制之刃",
		"魔棒",
		"两个铁树枝干",
		"先锋盾",
		"闪烁匕首",
		"洞察烟斗",
		"阿哈利姆神杖",
		"恐鳌之心",
		"希瓦的守护",
	},
	['Sell'] = {
		"赤红甲",
		"先锋盾",
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
	local order = {'Q','W','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end
	
end

return X
-- dota2jmz@163.com QQ:2462331592

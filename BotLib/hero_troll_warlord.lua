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
		['info'] = '通常',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {1,2,4,4,4,6,4,1,1,1,6,2,2,2,6},
		--装备
		['Buy'] = {
			"树之祭祀",
			"淬毒之珠",
			"压制之刃",
			"猎鹰战刃",
			"动力鞋",
			"疯狂面具",
			"散华",
			"阿哈利姆魔晶",
			"黑皇杖",
			"碎颅锤",
			"散夜对剑",
			"深渊之刃",
			"拆疯脸转撒旦",
		},
		--出售
		['Sell'] = {
			"阿哈利姆神杖2",
			"压制之刃",
			
			"远行鞋2",
			"动力鞋",

			"黯灭", 
			"猎鹰战刃",
		},
	},
	{
		--组合说明，不影响游戏
		['info'] = '狂战',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {1,2,4,4,4,6,4,1,1,1,6,2,2,2,6},
		--装备
		['Buy'] = {
			"树之祭祀",
			"淬毒之珠",
			"压制之刃",
			"猎鹰战刃",
			"动力鞋",
			"狂战斧",
			"疯狂面具",
			"阿哈利姆魔晶",
			"黑皇杖",
			"碎颅锤",
			"金箍棒", 
			"深渊之刃",
			"阿哈利姆神杖",
			"拆疯脸转撒旦",
			"银月之晶",
			"阿哈利姆神杖2",
		},
		--出售
		['Sell'] = {
			"远行鞋2",
			"动力鞋",
			
			"黯灭", 
			"猎鹰战刃",
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {0, 10},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	['Ability'] = {1,2,4,4,4,6,4,1,1,1,6,2,2,2,6},
	['Buy'] = {
		"树之祭祀",
		"淬毒之珠",
		"压制之刃",
		"枯萎之石",
		"动力鞋",
		"疯狂面具",
		"散华",
		"黑皇杖",
		"碎颅锤",
		"散夜对剑",
		"黯灭", 
		"深渊之刃",
		"拆疯脸转撒旦",
	},
	['Sell'] = {
		"阿哈利姆神杖2",
		"压制之刃",
	}
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData, true)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
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
	local order = {'Q','W','E','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
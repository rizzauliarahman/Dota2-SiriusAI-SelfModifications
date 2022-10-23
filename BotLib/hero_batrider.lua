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
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 3, 1, 3, 1, 6, 1, 3, 2, 3, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"力量手套",
			"两个魔法芒果",
			"两个魔法芒果",
			"两个铁树枝干",
			"魔棒",
			"风灵之纹",
			"护腕",
			"治疗药膏",
			"魔杖",
			"远行鞋",
			"回复戒指",
			"净化药水",
			"闪烁匕首",
			"原力法杖",
			"黑皇杖",
			"陨星锤", 
			"林肯法球",
			"阿哈利姆神杖2",
			"飓风长戟",
			"远行鞋2",
			"银月之晶"
		},
		--出售
		['Sell'] = {
			"原力法杖",     
			"风灵之纹",

			"黑皇杖",
			"护腕",     

			"陨星锤",
			"魔杖"
		},
	},
	{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		['Ability'] = { 1, 3, 3, 1, 3, 6, 2, 3, 1, 1, 6, 2, 2, 2, 6},
		['Buy'] = {
			"两个树之祭祀",
			"治疗药膏",
			"两个魔法芒果",
			"王冠",
			"魔棒",
			"速度之靴",
			"韧鼓",
			"闪烁匕首",
			"原力法杖",
			"以太透镜", 
			"远行鞋",
			"黑皇杖",
			"阿哈利姆神杖2",
			"希瓦的守护",
			"远行鞋2",
			"银月之晶"
		},
		['Sell'] = {
			"黑皇杖",
			"魔棒",

			"希瓦的守护",
			"韧鼓",
		}
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
	--装备
	['Buy'] = {
		"树之祭祀",
		"治疗药膏",
		"魔杖",
		"静谧之鞋",
		"闪烁匕首",
		"原力法杖",
		"黑皇杖",
		"Eul的神圣法杖",
		"阿哈利姆神杖",
		"飓风长戟",
		"玲珑心",
	},
	--出售
	['Sell'] = {
		"Eul的神圣法杖",
		"魔杖",
	},
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
	local order = {'R','E','W','Q'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X

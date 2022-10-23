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
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 2, 1, 2, 1, 2, 6, 3, 2, 3, 3, 6, 3, 1, 1, 6 },
		--装备
		['Buy'] = {
			"圆环",
			"树之祭祀",
			"魔法芒果",
			"净化药水",
			"治疗药膏",
			"魔棒",
			"魔法芒果",
			"净化药水",
			"奥术鞋",
			"影之灵龛",
			"魔杖",
			"以太透镜",
			"闪烁匕首",
			"微光披风",
			"阿哈利姆神杖",
			"魂之灵瓮",
			"阿哈利姆神杖2",
			"Eul的神圣法杖",
			"邪恶镰刀",
			"远行鞋2",
			"银月之晶",
		},
		--出售
		['Sell'] = {
			"阿哈利姆神杖",
			"魔杖",

			"远行鞋",
			"奥术鞋",
		},
	}
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {0, 10},
	},
	['Ability'] = { 1, 3, 1, 3, 2, 6, 1, 1, 3, 3, 6, 2, 2, 2, 6 },
	['Buy'] = {
		"枯萎之石",
		"两个树之祭祀",
		"净化药水",
		"魔法芒果",
		"魔棒",
		"两个魔法芒果",
		"魔杖",
		"风灵之纹",
		"勇气勋章",
		"奥术鞋",
		"迈达斯之手",
		"原力法杖",
		"卫士胫甲",
		"洞察烟斗",
		"炎阳纹章",
		"死灵书3",
		"邪恶镰刀",
		"阿哈利姆神杖2",
		"白银之锋",
		"银月之晶",
	},
	['Sell'] = {
		"永恒之盘",
		"魔杖",

		"死灵书3",
		"原力法杖",

		"白银之锋",
		"迈达斯之手",

		"白银之锋",
		"永恒之盘",
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
	local order = {'Q','W','D','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X

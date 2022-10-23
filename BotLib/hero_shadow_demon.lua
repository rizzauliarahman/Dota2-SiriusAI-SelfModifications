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
		['info'] = '主W加点',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {1,3,3,2,3,6,3,2,2,2,6,1,1,1,6},
		--装备
		['Buy'] = {
			"树之祭祀",
			"魔法芒果",
			"两个铁树枝干",
			"净化药水",
			"静谧之鞋",
			"原力法杖",
			"微光披风",
			"阿托斯之棍",
			"阿哈利姆神杖",
			"洞察烟斗",
			"天堂之戟",
		},
		--替换
		['Sell'] = {
			"赤红甲",
			"压制之刃",
		}
	},
	{
		['info'] = '主Q加点',
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		['Ability'] = {1,3,3,2,3,6,3,1,1,1,6,2,2,2,6},
		['Buy'] = {
			"树之祭祀",
			"魔法芒果",
			"两个铁树枝干",
			"净化药水",
			"静谧之鞋",
			"原力法杖",
			"微光披风",
			"阿托斯之棍",
			"阿哈利姆神杖",
			"洞察烟斗",
			"天堂之戟",
		},
		['Sell'] = {
			"赤红甲",
			"压制之刃",
		}
	},
	{
		['info'] = 'By Misunderstand',
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		['Ability'] = { 3, 1, 3, 2, 3, 6, 3, 2, 2, 2, 6, 1, 1, 1, 6 },
		['Buy'] = {
			"治疗药膏",
			"圆环",
			"两个净化药水",
			"树之祭祀",
			"风灵之纹",
			"空灵挂件",
			"两个魔法芒果",
			"魔杖",
			"净化药水",
			"静谧之鞋",
			"以太透镜",
			"原力法杖",
			"永恒之盘", 
			"阿哈利姆神杖",
			"梅肯斯姆", 
			"微光披风",
			"阿哈利姆神杖2",
			"远行鞋",
			"飓风长戟",
			"达贡之神力5",
			"银月之晶",
		},
		['Sell'] = {
			"阿哈利姆神杖",
			"空灵挂件",

			"梅肯斯姆",     
			"魔杖",

			"远行鞋",     
			"静谧之鞋",

			"达贡之神力",
			"梅肯斯姆"
		}
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
	['Ability'] = {1,3,3,2,3,6,3,1,1,1,6,2,2,2,6},
	['Buy'] = {
		"树之祭祀",
		"魔法芒果",
		"两个铁树枝干",
		"净化药水",
		"静谧之鞋",
		"原力法杖",
		"微光披风",
		"阿托斯之棍",
		"阿哈利姆神杖",
		"洞察烟斗",
		"天堂之戟",
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
	local order = {'E','D','R','W','Q'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
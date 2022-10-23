local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表
--编组技能、天赋、装备,以后独立出来，这个文件尽量小一些，增加可读性
local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = '主Q加点',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {2,3,1,1,1,6,1,2,2,2,6,3,3,3,6},
		--装备
		['Buy'] = {
			'树之祭祀',
			'两个魔法芒果',
			'压制之刃',
			'魔法芒果',
			'魔杖',
			'护腕',
			'相位鞋',
			'刃甲',
			'弗拉迪米尔的祭品',
			'回音战刃',
			'辉耀',
			'阿哈利姆魔晶',
			'强袭胸甲',
			'炎阳纹章',
			'阿哈利姆神杖2',
		},
		--出售
		['Sell'] = {
			'深渊之刃',
			'压制之刃',
		},
	},
	{
		--组合说明，不影响游戏
		['info'] = '主被动加点',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = {2,3,2,3,2,6,1,3,2,3,1,1,1,6,6},
		--装备
		['Buy'] = {
			'树之祭祀',
			'两个魔法芒果',
			'魔法芒果',
			'压制之刃',
			'魔杖',
			'护腕',
			'相位鞋',
			'猎鹰战刃',
			'刃甲',
			'回音战刃',
			'闪烁匕首',
			'辉耀',
			'希瓦的守护',
			'深渊之刃',
			'阿哈利姆魔晶',
			'恐鳌之心',
		},
		--出售
		['Sell'] = {
			'雷神之锤',
			'压制之刃',

			'盛势闪光',
			'闪烁匕首',
		},
	},
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
		['Ability'] = { 1, 2, 1, 2, 1, 6, 3, 1, 2, 2, 6, 3, 3, 3, 6},
		--装备
		['Buy'] = {
			"树之祭祀",
			"治疗药膏",
			"魔法芒果",
			"压制之刃",
			"魔棒",
			"魔杖",
			"相位鞋",
			"两个魔法芒果",
			"韧鼓",
			"勇气勋章",
			"弗拉迪米尔的祭品",
			"辉耀",
			"魂之灵瓮",
			"炎阳纹章",
			"阿哈利姆神杖2",
			"幻影斧",
			"天堂之戟",
			"远行鞋2",
			"银月之晶",
		},
		--出售
		['Sell'] = {
			"韧鼓",
			"压制之刃",
			
			"辉耀",
			"魔杖",

			"幻影斧",
			"韧鼓",
			
			"天堂之戟",
			"弗拉迪米尔的祭品",
			
			"远行鞋",
			"相位鞋",
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	['Ability'] = {2,1,1,3,1,6,1,2,2,2,6,3,3,3,6},
	['Buy'] = {
		'树之祭祀',
		'治疗药膏',
		'压制之刃',
		'灵魂之戒',
		'相位鞋',
		'刃甲',
		'雷神之锤',
		'散夜对剑',
		'辉耀',
		'撒旦之邪力',
		'恐鳌之心',
	},
	['Sell'] = {
		'赤红甲',
		'压制之刃',
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
	local order = {'Q','W'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X;
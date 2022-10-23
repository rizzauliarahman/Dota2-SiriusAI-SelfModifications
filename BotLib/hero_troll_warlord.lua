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
			"item_tango",
			"item_orb_of_venom",
			"item_quelling_blade",
			"item_falcon_blade",
			"item_power_treads",
			"item_mask_of_madness",
			"item_sange",
			"item_aghanims_shard",
			"item_black_king_bar",
			"item_basher",
			"item_sange_and_yasha",
			"item_abyssal_blade",
			"item_broken_satanic",
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter2",
			"item_quelling_blade",
			
			"item_travel_boots2",
			"item_power_treads",

			"item_desolator", 
			"item_falcon_blade",
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
			"item_tango",
			"item_orb_of_venom",
			"item_quelling_blade",
			"item_falcon_blade",
			"item_power_treads",
			"item_bfury",
			"item_mask_of_madness",
			"item_aghanims_shard",
			"item_black_king_bar",
			"item_basher",
			"item_monkey_king_bar", 
			"item_abyssal_blade",
			"item_ultimate_scepter",
			"item_broken_satanic",
			"item_moon_shard",
			"item_ultimate_scepter2",
		},
		--出售
		['Sell'] = {
			"item_travel_boots2",
			"item_power_treads",
			
			"item_desolator", 
			"item_falcon_blade",
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
		"item_tango",
		"item_orb_of_venom",
		"item_quelling_blade",
		"item_blight_stone",
		"item_power_treads",
		"item_mask_of_madness",
		"item_sange",
		"item_black_king_bar",
		"item_basher",
		"item_sange_and_yasha",
		"item_desolator", 
		"item_abyssal_blade",
		"item_broken_satanic",
	},
	['Sell'] = {
		"item_ultimate_scepter2",
		"item_quelling_blade",
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
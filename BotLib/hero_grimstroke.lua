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
			"item_circlet",
				"item_tango",
				"item_clarity",
				"item_enchanted_mango",
				"item_flask",
				"item_magic_stick",
				"item_infused_raindrop",
				"item_tango",
				"item_clarity",
				"item_enchanted_mango",
				"item_urn_of_shadows", 
				"item_arcane_boots",
				"item_aether_lens",
				"item_glimmer_cape",
				"item_aghanims_shard",
				"item_spirit_vessel",
				"item_heavens_halberd",
				"item_sheepstick",
				"item_ultimate_scepter2",
				"item_travel_boots", 
				"item_ethereal_blade"
		},
		['Sell'] = {
			"item_travel_boots",     
			"item_arcane_boots", 
	
			"item_ethereal_blade",
			"item_glimmer_cape" 
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
			"两个item_enchanted_mango",
			"item_tango",
			"item_enchanted_mango",
			"item_magic_stick",
			"item_arcane_boots",
			"item_aether_lens",
			"item_glimmer_cape",
			"item_aghanims_shard",
			"item_rod_of_atos",
			"item_heavens_halberd",
			"item_sheepstick",
			"item_gungir",
			"item_ultimate_scepter2",
		},
		['Sell'] = {
			"item_travel_boots",     
			"item_arcane_boots", 
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
		"item_tango",
		"item_enchanted_mango",
		"两个item_branches",
		"item_enchanted_mango",
		"item_clarity",
		"item_arcane_boots",
		"item_rod_of_atos",
		"item_glimmer_cape",
		"item_ultimate_scepter",
		"item_cyclone",
		"item_sheepstick",
		"item_force_staff",
		"item_bloodthorn",
		"item_necronomicon3",
	},
	['Sell'] = {
		"item_crimson_guard",
		"item_quelling_blade",
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

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
			"item_tango",
			"item_gauntlets",
			"两个item_branches",
			"item_magic_wand",
			"item_bracer",
			"item_enchanted_mango",
			"item_phase_boots",
			"item_vanguard",
			"item_blink",
			"item_hood_of_defiance",
			"item_aghanims_shard",
			"item_radiance",
			"item_pipe",
			"item_crimson_guard",
			"item_heart",
			"item_overwhelming_blink",
			"item_ultimate_scepter2",
			"item_travel_boots",
			"item_moon_shard",
			"item_travel_boots2"
		},
		['Sell'] = {
			"item_hood_of_defiance",     
			"item_bracer",

			"item_heart",     
			"item_magic_wand",
					
			"item_travel_boots",
			"item_phase_boots"
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
			"item_tango",
			"item_flask",
			"两个item_enchanted_mango",
			"item_gauntlets",
			"item_magic_stick",
			"item_bracer",
			"item_magic_wand",
			"item_phase_boots",
			"item_vanguard",
			"item_hood_of_defiance", 
			"item_blink",
			"item_solar_crest",
			"item_aghanims_shard",
			"item_crimson_guard",
			"item_ultimate_scepter",
			"item_pipe",
			"item_heart",
			"item_overwhelming_blink",
			"item_ultimate_scepter2",
			"item_shivas_guard",
			"item_travel_boots2",
			"item_moon_shard"
		},
		['Sell'] = {
			"item_crimson_guard",
			"item_bracer",

			"item_ultimate_scepter",
			"item_magic_stick",

			"item_ultimate_scepter",     
			"item_bracer",

			"item_travel_boots2",
			"item_phase_boots"
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
			"item_tango",
			"item_quelling_blade",
			"两个item_enchanted_mango",
			"item_gauntlets",
			"item_magic_stick",
			"item_bracer",
			"item_magic_wand",
			"item_phase_boots",
			"item_vanguard",
			"item_hood_of_defiance", 
			"恐鳌之戒",
			"item_basher",
			"item_heart",
			"item_shivas_guard",
			"item_ultimate_scepter",
			"item_abyssal_blade",
			"item_ultimate_scepter2",
			"item_moon_shard"
		},
		['Sell'] = {
			"item_lotus_orb",
			"item_bracer",

			"item_sange_and_yasha",
			"item_hood_of_defiance",

			"item_travel_boots2",
			"item_phase_boots"
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
		"item_tango",
		"item_flask",
		"item_quelling_blade",
		"item_magic_stick",
		"两个item_branches",
		"item_vanguard",
		"item_blink",
		"item_pipe",
		"item_ultimate_scepter",
		"item_heart",
		"item_shivas_guard",
	},
	['Sell'] = {
		"item_crimson_guard",
		"item_vanguard",
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

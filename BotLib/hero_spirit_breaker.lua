local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--编组技能、天赋、装备
local tGroupedDataList = {}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {0, 10},
	},
	['Ability'] = {3,1,3,2,3,6,3,2,2,2,6,1,1,1,6},
	['Buy'] = {
		"两个item_tango",
		"item_orb_of_venom",
		"item_branches",
		"item_enchanted_mango",
		"item_magic_wand",
		"item_bracer",
		"item_boots",
		"item_bracer",
		"item_gloves",
		"item_urn_of_shadows",
		"item_hand_of_midas",
		"item_power_treads",
		"item_blade_mail",
		"item_black_king_bar",
		"item_heavens_halberd",
	},
	['Sell'] = {
		"item_assault",
		"item_magic_stick",

		"item_heart",
		"item_orb_of_venom",

		"item_silver_edge",
		"item_hand_of_midas",
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
		if hMinionUnit:IsIllusion() 
		then 
			Minion.IllusionThink(hMinionUnit)	
		end
	end

end

local hEnemyOnceLocation = {}

for _,TeamPlayer in pairs( GetTeamPlayers(GetOpposingTeam()) )
do
    hEnemyOnceLocation[TeamPlayer] = nil;
end

local hEnemyRecordLocation = {}
local abilityCD = nil;

function X.SkillsComplement()

	if bot:HasModifier("modifier_spirit_breaker_charge_of_darkness") then
		bot:Action_ClearActions(false);
		return
	end

	if abilityCD == nil then abilityCD = bot:GetAbilityByName( "spirit_breaker_charge_of_darkness" ) end

	if ( bot:HasModifier("modifier_spirit_breaker_charge_of_darkness") 
	   or J.CanNotUseAbility(bot) or bot:NumQueuedActions() > 0 ) 
	then return 
	end

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	if abilityCD:GetCooldownTimeRemaining() > 0 and bot.chargeTarget ~= nil 
	then bot.chargeTarget = nil end

	--技能检查顺序
	local order = {'Q','W','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
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
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	['Ability'] = {1,2,2,1,2,6,1,1,2,4,6,4,4,4,6},
	['Buy'] = {
		"item_enchanted_mango",
		"两个item_enchanted_mango",
		"item_tango",
		"item_orb_of_venom",
		"item_bracer",
		"item_magic_stick",
		"item_phase_boots",
		"item_urn_of_shadows",
		"item_rod_of_atos",
		"item_necronomicon",
		"item_ultimate_scepter",
		"item_basher",
		"item_sheepstick",
		"item_abyssal_blade"
	},
	['Sell'] = {
		"item_ethereal_blade",
		"item_orb_of_venom",
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
	   and (
			hMinionUnit:GetUnitName() ~= "npc_dota_beastmaster_boar_1" or
			hMinionUnit:GetUnitName() ~= "npc_dota_beastmaster_boar_2" or
			hMinionUnit:GetUnitName() ~= "npc_dota_beastmaster_boar_3" or
			hMinionUnit:GetUnitName() ~= "npc_dota_beastmaster_boar_4" 
		)
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

local hEnemyOnceLocation = {}

for _,TeamPlayer in pairs( GetTeamPlayers(GetOpposingTeam()) )
do
    hEnemyOnceLocation[TeamPlayer] = nil;
end

local hEnemyRecordLocation = {}

function X.SkillsComplement()
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'R','Q','W','E'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
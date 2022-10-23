----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sOutfitType = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,6,1,2,2,2,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_mage_outfit",
	"item_dragon_lance",
	"item_maelstrom",
	"item_force_staff",
--	"item_aghanims_shard",
--	"item_ultimate_scepter",
	"item_sheepstick",
	"item_hurricane_pike",
	"item_shivas_guard",
	"item_gungir",
	"item_moon_shard",
--	"item_ultimate_scepter_2",
	"item_monkey_king_bar",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = {

	"item_priest_outfit",
	"item_urn_of_shadows",
	"item_mekansm",
	"item_glimmer_cape",
--	"item_aghanims_shard",
	"item_guardian_greaves",
	"item_spirit_vessel",
	"item_vladmir",
--	"item_ultimate_scepter",
	"item_shivas_guard",
	"item_moon_shard",
--	"item_ultimate_scepter_2",
	"item_sheepstick",

}

tOutFitList['outfit_mage'] = {

	"item_mage_outfit",
	"item_glimmer_cape",
	"item_pipe",
	"item_veil_of_discord",
	"item_cyclone",
	"item_sheepstick",
	"item_wind_waker",
	"item_moon_shard",

}

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_shivas_guard",
	"item_magic_wand",
	
	"item_sheepstick",
	"item_magic_wand",

}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_windrunner

"Ability1"		"windrunner_shackleshot"
"Ability2"		"windrunner_powershot"
"Ability3"		"windrunner_windrun"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"windrunner_focusfire"
"Ability10"		"special_bonus_mp_regen_150"
"Ability11"		"special_bonus_unique_windranger_9"
"Ability12"		"special_bonus_unique_windranger_3"
"Ability13"		"special_bonus_attack_range_100"
"Ability14"		"special_bonus_unique_windranger_6"
"Ability15"		"special_bonus_unique_windranger_8"
"Ability16"		"special_bonus_unique_windranger"
"Ability17"		"special_bonus_cooldown_reduction_25"

modifier_windrunner_shackle_shot
modifier_windrunner_windrun_invis
modifier_windrunner_windrun
modifier_windrunner_windrun_slow
modifier_windrunner_focusfire


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )
local talent2 = bot:GetAbilityByName( sTalentList[2] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget
local castASDesire, castASTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.SkillsComplement()
	
	
	
	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	castASDesire, castASTarget, sMotive = X.ConsiderAS()
	if castASDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityAS, castASTarget )
		return
	end
	
	
	if true then return end
	
	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	--计算天赋可能带来的通用变化
	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end

	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if castWDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWTarget )
		return
	end

	castEDesire, castETarget, sMotive = X.ConsiderE()
	if castEDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityE, castETarget )
		return
	end

	castRDesire, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityR )
		return
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( 'dam' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil




	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetSpecialValueInt( 'dam' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil



	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end

	local nSkillLV = abilityE:GetLevel()
	local nCastRange = abilityE:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityE:GetCastPoint()
	local nManaCost = abilityE:GetManaCost()
	local nDamage = abilityE:GetSpecialValueInt( 'dam' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil



	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetSpecialValueInt( 'dam' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil



	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderAS()


	if not abilityAS:IsTrained()
		or not abilityAS:IsFullyCastable() 
	then return 0 end

	if bot:GetActiveMode() == BOT_MODE_RETREAT
	then

		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 900, 400, 0, 0 )
		if locationAoE.count >= 2
			or ( locationAoE.count >= 1 and bot:GetHealth()/bot:GetMaxHealth() < 0.5 )
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc, "AOE2"
		end

		local nInRangeEnemyList = J.GetAroundEnemyHeroList( 800 )
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and GetUnitToUnitDistance( bot, npcEnemy ) <= 800
			then
				return BOT_ACTION_DESIRE_HIGH, ( bot:GetLocation() + npcEnemy:GetLocation() ) * 0.5, "retreat"
			end
		end
	end



	return BOT_ACTION_DESIRE_NONE


end


return X
-- dota2jmz@163.com QQ:2462331592




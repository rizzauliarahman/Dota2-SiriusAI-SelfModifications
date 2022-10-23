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

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)


local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
	{3,1,1,2,1,6,1,2,2,2,6,3,3,3,6},
	{1,3,3,2,3,6,1,3,1,1,6,2,2,2,6}
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
	"item_tango",
    "item_flask",
    "item_magic_stick",
    "item_double_branches",
	"item_magic_wand",
	"item_tranquil_boots",
	"item_glimmer_cape",
	"item_force_staff",
	"item_ultimate_scepter",
	"item_rod_of_atos",
	"item_sheepstick",
	"item_hurricane_pike",
	"item_ultimate_scepter_2",
	"item_octarine_core"
}

X['sSellList'] = {
	"item_shivas_guard",
	"item_magic_wand",
}

if J.Role.IsPvNMode() then X['sBuyList'],X['sSellList'] = { 'PvN_priest' }, {} end

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)	
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityD = bot:GetAbilityByName( "ancient_apparition_ice_blast_release" )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castWDesire, castWLocation
local castEDesire, castETarget
local castDDesire
local castRDesire, castRLocation

local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget,sMotive;
local aetherRange = 0
local ReleaseLoc = {};

function X.SkillsComplement()
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	botTarget = J.GetProperTarget(bot);
	hEnemyList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1600);
	
	
	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end	
	
	castDDesire = X.ConsiderD();
	if ( castDDesire > 0 ) 
	then
		bot:ActionQueue_UseAbility( abilityD )

		return;
	end

	castEDesire, castETarget = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return;
	end

	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
		J.SetQueuePtToINT(bot, true)

		local typeAOE = X.CheckFlag(abilityQ:GetBehavior(), ABILITY_BEHAVIOR_POINT);
		if typeAOE == true then
			bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQTarget:GetLocation() );
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget );
		end
		
		return;
	end

	castRDesire, castRLocation = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation )
		ReleaseLoc = castRLocation;
		return;
	
	end
	
	castWDesire, castWLocation = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return;
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end
	
	-- Get some of its values
	local nCastRange = abilityQ:GetCastRange();
	if nCastRange + 200 > 1600 then nCastRange = 1300; end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange + 200) and not npcTarget:HasModifier("modifier_ancient_apparition_cold_feet")
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
	
end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() or abilityW:IsHidden() then return 0 end
	
	-- Get some of its values
	local nRadius = abilityW:GetSpecialValueInt("radius");
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();
	
	if nCastRange + 200 > 1600 then nCastRange = 1300; end

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				return BOT_ACTION_DESIRE_LOW, npcEnemy:GetExtrapolatedLocation(nCastPoint)
			end
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  ( J.IsDefending(bot) or J.IsPushing(bot) ) and bot:GetMana() / bot:GetMaxMana() > 0.75
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsInRange(npcTarget, bot, nCastRange+200) and not npcEnemy:HasModifier("modifier_ancient_apparition_ice_vortex_thinker") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if  J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange+200) and not npcTarget:HasModifier("modifier_ancient_apparition_ice_vortex_thinker") 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() or abilityE:IsHidden() then return 0 end
	
	-- Get some of its values
	local nCastRange = bot:GetAttackRange();

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_VERYHIGH, npcTarget;
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
	
end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() or abilityR:IsHidden() then return 0 end
	
	local nSpeed = abilityR:GetSpecialValueInt("speed");
	local nCastPoint = abilityR:GetCastPoint();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				return BOT_ACTION_DESIRE_LOW, npcEnemy:GetLocation();
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) 
		then
			local nTime = GetUnitToUnitDistance(npcTarget, bot) / nSpeed;
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nTime + nCastPoint);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderD()


	if not abilityD:IsFullyCastable() or abilityD:IsHidden() then return 0 end
	
	local nRadius = 1000;
	
	local pro = GetLinearProjectiles();
	for _,pr in pairs(pro)
	do
		if pr ~= nil and pr.ability:GetName() == "ancient_apparition_ice_blast"  then
			if ReleaseLoc ~= nil and X.GetDistance(ReleaseLoc, pr.location) < 100 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1;
end

function X.GetDistance(s, t)
    if s == nil or t == nil then return end
    --print("S1: "..s[1]..", S2: "..s[2].." :: T1: "..t[1]..", T2: "..t[2]);
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

return X
-- dota2jmz@163.com QQ:2462331592。





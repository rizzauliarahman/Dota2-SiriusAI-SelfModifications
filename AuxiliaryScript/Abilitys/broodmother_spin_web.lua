-----------------
--英雄：育母蜘蛛
--技能：织网
--键位：W
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('broodmother_spin_web')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;
local timeCast = 0

nKeepMana = 500 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    if castTarget ~= nil and DotaTime() >= timeCast + 0.8 then
        X.Compensation()
		bot:ActionQueue_UseAbilityOnLocation( ability, castTarget ) --使用技能
		timeCast = DotaTime()
    end
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()

	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
	   or not ability:IsFullyCastable()
	   or bot:IsCastingAbility() 
	   or ability:IsInAbilityPhase() 
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	-- Get some of its values
	local nRadius = ability:GetSpecialValueInt( "radius" );
	local nCastRange = 900;
	local nCastPoint = ability:GetCastPoint( );
    
	--[[if DotaTime() > 15 and bot:DistanceFromFountain() > 1000 and not LocationOverlapWeb( bot:GetXUnitsInFront(nCastRange), nRadius ) then
		return BOT_ACTION_DESIRE_MODERATE, bot:GetXUnitsInFront(nCastRange);
	end]]--
	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and 
				not LocationOverlapWeb(GetTowardsFountainLocation( bot:GetLocation(), nCastRange ), nRadius) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, GetTowardsFountainLocation( bot:GetLocation(), nCastRange );
			end
		end
	end

	if J.IsPushing(bot) 
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		local NearbyTower = bot:GetNearbyTowers(nRadius, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius / 3, 0, 0 );
		if locationAoE.count >= 3 and #lanecreeps >= 3 and not LocationOverlapWeb(locationAoE.targetloc, nRadius) then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
		if NearbyTower[1] ~= nil and not NearbyTower[1]:IsInvulnerable() and 
			not LocationOverlapWeb(NearbyTower[1]:GetLocation(), nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE, NearbyTower[1]:GetLocation();
		end
	end
	
	if J.IsDefending(bot)
	then
		local NearbyTower = bot:GetNearbyTowers(nRadius, false);
		if NearbyTower[1] ~= nil and not NearbyTower[1]:IsInvulnerable() and 
			not LocationOverlapWeb(NearbyTower[1]:GetLocation(), nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE, NearbyTower[1]:GetLocation();
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( 800, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4 and not LocationOverlapWeb(bot:GetLocation(), nRadius) then
			return BOT_MODE_DESIRE_MODERATE, bot:GetLocation();
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if  J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange) and 
			not LocationOverlapWeb(npcTarget:GetExtrapolatedLocation( nCastPoint ), nRadius)   
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function LocationOverlapWeb(location, nRadius)
	local flag = ( 1.5*nRadius ) + 150;
	local unit = GetUnitList(UNIT_LIST_ALLIES);
	for _,u in pairs (unit)
	do
		if u:GetUnitName() == "npc_dota_broodmother_web"
		then
			if GetUnitToLocationDistance(u, location) <= flag then
				return true
			end
		end
	end
	return false;
end

function GetTowardsFountainLocation( unitLoc, distance )
	local destination = {};
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt(2);
		destination[2] = unitLoc[2] - distance / math.sqrt(2);
	end

	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt(2);
		destination[2] = unitLoc[2] + distance / math.sqrt(2);
	end
	return Vector(destination[1], destination[2]);
end

return X;
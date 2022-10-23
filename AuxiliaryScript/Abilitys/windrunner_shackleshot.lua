-----------------
--英雄：风行者
--技能：束缚击
--键位：Q
--类型：指向单位
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('windrunner_shackleshot')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 180 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    if castTarget ~= nil then
        X.Compensation()
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
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
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

    local nCastPoint = ability:GetCastPoint();
	local manaCost   = ability:GetManaCost();
	local nRadius    = ability:GetSpecialValueInt('shackle_distance') - 125;
	local nCastRange    = GetProperCastRange(false, bot, ability:GetCastRange());
	
	if ( J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		for i=1, #enemies do
			if J.IsValidHero(enemies[i]) 
				and J.CanCastOnNonMagicImmune(enemies[i]) 
				and J.IsDisabled(enemies[i]) == false
			then	
				local starget = GetShackleTarget(bot, enemies[i], nRadius, GetUnitToUnitDistance(enemies[i], bot))
				if starget ~= nil then
					return BOT_ACTION_DESIRE_MODERATE, starget;
				end
			end	
		end
	end
	
	if J.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(target, bot, nCastRange+nRadius)
			and J.IsDisabled(target) == false
		then
			local starget = GetShackleTarget(bot, target, nRadius, GetUnitToUnitDistance(target, bot))
			if starget ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, starget;
			end
		end
	end
	
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	for i=1, #enemies do
		if J.IsValidHero(enemies[i]) == true 
			and J.CanCastOnNonMagicImmune(enemies[i]) == true 
			and ( enemies[i]:IsChanneling()
			or enemies[i]:HasModifier('modifier_teleporting') )
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i];
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function GetProperCastRange(bIgnore, hUnit, abilityCR)
	local attackRng = hUnit:GetAttackRange();
	if bIgnore then
		return abilityCR;
	elseif abilityCR <= attackRng then
		return attackRng + 200;
	elseif abilityCR + 200 <= 1600 then
		return abilityCR + 200;
	elseif abilityCR > 1600 then
		return 1600;
	else
		return abilityCR;
	end
end

function GetShackleTarget(hero, target, nRadius, nRange)
	local sTarget = nil;
	local dist = GetUnitToUnitDistance(hero, target);
	if dist < nRange and CanShackleToCreep(hero, target, nRadius) 
		or CanShackleToHero(hero, target, nRadius)
		or CanShackleToTree(hero, target, nRadius)
	then
		sTarget = target;
	elseif dist < nRange or dist < nRange+nRadius then
		sTarget = GetShackleCreepTarget(hero, target, nRadius);
		if sTarget == nil then
			sTarget = GetShackleHeroTarget(hero, target, nRadius);
		end
	end
	return sTarget;
end

function GetShackleCreepTarget(hSource, hTarget, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = hTarget:GetLocation();
	local creeps = hTarget:GetNearbyCreeps(nRadius, false);
	for i=1, #creeps do
		local dist1 = GetUnitToUnitDistance(creeps[i], hTarget);
		local dist2 = GetUnitToUnitDistance(creeps[i], hSource);
		local dist3 = GetUnitToUnitDistance(hTarget, hSource);
		if  dist2 < dist3 and dist1 > 125  then
			local tResult = PointToLineDistance(vStart, vEnd, creeps[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true 
				and tResult.distance < 75
			then
				-- print('to creep in front')
				return creeps[i];
			end
		end
	end
	return nil;
end

function GetShackleHeroTarget(hSource, hTarget, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = hTarget:GetLocation();
	local heroes = hTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
	for i=1, #heroes do
		if heroes[i] ~= hTarget and J.CanCastOnNonMagicImmune(heroes[i]) then
			local dist1 = GetUnitToUnitDistance(heroes[i], hTarget);
			local dist2 = GetUnitToUnitDistance(heroes[i], hSource);
			local dist3 = GetUnitToUnitDistance(hTarget, hSource);
			if  dist2 < dist3 and dist1 > 125  then
				local tResult = PointToLineDistance(vStart, vEnd, heroes[i]:GetLocation());
				if tResult ~= nil 
					and tResult.within == true 
					and tResult.distance < 75	
				then
					-- print('to hero in front')
					return heroes[i];
				end
			end
		end
	end
	return nil;
end

function CanShackleToHero(hSource, hTarget, nRadius)
	local vStart = hSource:GetLocation();
	local heroes = hTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
	for i=1, #heroes do
		local vEnd = heroes[i]:GetLocation()
		local tResult = PointToLineDistance(vStart, vEnd, hTarget:GetLocation());
		if heroes[i] ~= hTarget and GetUnitToUnitDistance(heroes[i], hTarget) > 125 and tResult ~= nil 
			and tResult.within == true  
			and tResult.distance < 75 			
		then
			-- print('to hero behind')
			return true;
		end
	end
	return false;
end

function CanShackleToTree(hSource, hTarget, nRadius)
	local vStart = hSource:GetLocation();
	local trees = hTarget:GetNearbyTrees(nRadius);
	for i=1, #trees do
		local vEnd = GetTreeLocation(trees[i]);
		local tResult = PointToLineDistance(vStart, vEnd, hTarget:GetLocation());
		if tResult ~= nil 
			and tResult.within == true 
			and tResult.distance < 75 			
		then
			-- print('to tree behind')
			return true;
		end
	end
	return false;
end

function CanShackleToCreep(hSource, hTarget, nRadius)
	local vStart = hSource:GetLocation();
	local creeps = hTarget:GetNearbyCreeps(nRadius, false);
	for i=1, #creeps do
		local vEnd = creeps[i]:GetLocation()
		local tResult = PointToLineDistance(vStart, vEnd, hTarget:GetLocation());
		if GetUnitToUnitDistance(creeps[i], hTarget) > 125 and tResult ~= nil 
			and tResult.within == true  			
			and tResult.distance < 75  			
		then
			-- print('to creep behind')
			return true;
		end
	end
	return false;
end

return X;
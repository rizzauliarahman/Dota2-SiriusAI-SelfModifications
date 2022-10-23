-----------------
--英雄：帕吉
--技能：肉钩
--键位：Q
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('pudge_meat_hook')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;
local camps = GetNeutralSpawners();

nKeepMana = 300 --魔法储量
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
    if castTarget ~= nil then
		X.Compensation()
		bot:Action_ClearActions(false);
        bot:ActionQueue_UseAbilityOnLocation( ability, castTarget ) --使用技能
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
	   or ability:IsTrained() 
	   or ability:IsHidden() == false
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nCastPoint = ability:GetCastPoint();
	local manaCost   = ability:GetManaCost();
	local nRadius    = ability:GetSpecialValueInt('hook_width');
	local speed    	 = ability:GetSpecialValueInt('hook_speed');
	local nCastRange = GetProperCastRange(false, bot, ability:GetCastRange())-300;
	
	if J.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) 
			and J.CanCastOnMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),15) 
			and J.IsInRange(bot, target, nCastRange)
		then
			-- if moveST ~= target:GetUnitName() or target:GetMovementDirectionStability() ~= moveS then
				-- print(target:GetUnitName().." : "..tostring(target:GetMovementDirectionStability()))
				-- moveST = target:GetUnitName();
				-- moveS = target:GetMovementDirectionStability();
			-- end
			local allies = bot:GetNearbyHeroes(150, false, BOT_MODE_NONE);
			if #allies <= 1 then
				local distance = GetUnitToUnitDistance(target, bot)
				local moveCon = target:GetMovementDirectionStability();
				local pLoc = target:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 0.65 then
					pLoc = target:GetLocation();
				end
				if IsAllyHeroBetweenMeAndTarget(bot, target, pLoc, nRadius) == false 
					and IsCreepBetweenMeAndTarget(bot, target, pLoc, nRadius) == false
				then
					return BOT_ACTION_DESIRE_MODERATE, pLoc;
				end
			end
		end
	end
	
	local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_RETREAT);
	if #allies > 0 then
		local botBaseDist = bot:DistanceFromFountain();
		for i=1, #allies do
			if J.IsValidHero(allies[i])
				and allies[i] ~= bot
				and J.CanCastOnMagicImmune(allies[i])
				and allies[i]:WasRecentlyDamagedByAnyHero(5.0)
				and allies[i]:GetHealth() < 0.5*allies[i]:GetMaxHealth()
				and ( allies[i]:GetTarget() == nil or allies[i]:GetAttackTarget() == nil )
				and allies[i]:DistanceFromFountain() > botBaseDist
				and GetUnitToUnitDistance(allies[i], bot) > 0.5*nCastRange
			then
				local distance = GetUnitToUnitDistance(allies[i], bot)
				local moveCon = allies[i]:GetMovementDirectionStability();
				local pLoc = allies[i]:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 0.65 then
					pLoc = allies[i]:GetLocation();
				end
				if IsHeroBetweenMeAndTarget(bot, allies[i], pLoc, nRadius) == false 
					and IsCreepBetweenMeAndTarget(bot, allies[i], pLoc, nRadius) == false
				then
					return BOT_ACTION_DESIRE_MODERATE, pLoc;
				end
			end	
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

function IsAllyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local heroes = hSource:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i,hero in pairs(heroes) do
		if hero ~= hSource then
			local tResult = PointToLineDistance(vStart, vEnd, hero:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
				return true;
			end
		end
	end
	heroes = hTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i,hero in pairs(heroes) do
		if hero ~= hSource then
			local tResult = PointToLineDistance(vStart, vEnd, hero:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
				return true;
			end
		end
	end
	return false;
end

function IsCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	if not IsAllyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius) then
		return IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius);
	end
	return true;
end

function IsHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	if not IsAllyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius) then
		return IsEnemyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius);
	end
	return true;
end

function IsAllyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local creeps = hSource:GetNearbyLaneCreeps(1600, false);
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
			return true;
		end
	end
	creeps = hTarget:GetNearbyLaneCreeps(1600, true);
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
			return true;
		end
	end
	return false;
end

function IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local creeps = hSource:GetNearbyLaneCreeps(1600, true);
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
			return true;
		end
	end
	creeps = hTarget:GetNearbyLaneCreeps(1600, false);
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
			return true;
		end
	end
	return false;
end

function IsHeroBetweenMeAndLocation(source, endLoc, radius)
	local vStart = source:GetLocation();
	local vEnd = endLoc;
	local enemy_heroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i=1, #enemy_heroes do
		if enemy_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, enemy_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	local ally_heroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i=1, #ally_heroes do
		if ally_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, ally_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	return false;
end

function IsCreepBetweenMeAndLocation(source, endLoc, radius)
	local vStart = source:GetLocation();
	local vEnd = endLoc;
	local enemy_heroes = bot:GetNearbyLaneCreeps(1600, true);
	for i=1, #enemy_heroes do
		local tResult = PointToLineDistance(vStart, vEnd, enemy_heroes[i]:GetLocation());
		if tResult ~= nil 
			and tResult.within == true  
			and tResult.distance < radius + 25 			
		then
			return true;
		end
	end
	local ally_heroes = bot:GetNearbyLaneCreeps(1600, false);
	for i=1, #ally_heroes do
		local tResult = PointToLineDistance(vStart, vEnd, ally_heroes[i]:GetLocation());
		if tResult ~= nil 
			and tResult.within == true  
			and tResult.distance < radius + 25 			
		then
			return true;
		end
	end
	return false;
end

function IsEnemyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local heroes = hSource:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i,hero in pairs(heroes) do
		if hero ~= hTarget  then
			local tResult = PointToLineDistance(vStart, vEnd, hero:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
				return true;
			end
		end
	end
	heroes = hTarget:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i,hero in pairs(heroes) do
		if hero ~= hTarget  then
			local tResult = PointToLineDistance(vStart, vEnd, hero:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
				return true;
			end
		end
	end
	return false;
end

return X;
-----------------
--英雄：帕克
--技能：幻象法球
--键位：Q
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('puck_illusory_orb')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;
X.illuOrbLoc = nil

nKeepMana = 400 --魔法储量
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
        X.illuOrbLoc = castTarget
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
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	local nCastPoint = ability:GetCastPoint();
	local manaCost   = ability:GetManaCost();
	local nRadius    = ability:GetSpecialValueInt('radius');
	local nCastRange = GetProperCastRange(false, bot, ability:GetCastRange());
	
	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation( bot,  loc, nCastRange );
	end
	
	if ( J.IsRetreating(bot) and ( bot:WasRecentlyDamagedByAnyHero(3.0) or bot:WasRecentlyDamagedByTower(3.0) ) )
	then
		local loc = J.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation( bot,  loc, nCastRange - 250 );
	end
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) and  CanSpamSpell(bot, manaCost) 
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
		locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if J.IsInTeamFight(bot, 1300) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end	
		end
	end
	
	if J.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) == true
			and J.CanCastOnNonMagicImmune(target) == true
			and J.IsInRange(bot, target, nCastRange) == true	
		then
			return BOT_ACTION_DESIRE_MODERATE, target:GetLocation();
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

function CanSpamSpell(bot, manaCost)
	local initialRatio = 1.0;
	if manaCost < 100 then
		initialRatio = 0.6;
	end
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( initialRatio - bot:GetLevel()/(3*30) );
end

function CountUnitsNearLocation(pierceImmune, hUnits, vLoc, nRadius)
	local nUnits = 0;
	if hUnits ~= nil then
		for i=1, #hUnits do
			if	GetUnitToLocationDistance(hUnits[i], vLoc) <= nRadius 
				and ( ( pierceImmune and J.CanCastOnMagicImmune(hUnits[i]) ) or ( not pierceImmune and J.CanCastOnNonMagicImmune(hUnits[i]) ) ) 
			then
				nUnits = nUnits + 1;
			end
		end
	end
	return nUnits;
end

return X;
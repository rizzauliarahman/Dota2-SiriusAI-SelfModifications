-----------------
--英雄：玛尔斯
--技能：战神迅矛
--键位：Q
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('mars_spear')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

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
    if castTarget ~= nil then
        X.Compensation() 
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
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
    local castRange = X.GetProperCastRange(false, bot, ability);
	local castPoint = ability:GetCastPoint();
	local manaCost  = ability:GetManaCost();
	local nRadius   = ability:GetSpecialValueInt( "spear_width" );
	local nDuration = 1;
	local nSpeed    = ability:GetSpecialValueInt('spear_speed');
	local nDamage   = ability:GetSpecialValueInt('damage');
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);

	if J.IsRetreating(bot)
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			local enemy = X.GetLowestHPUnit(enemies, false);
			if enemy ~= nil then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
			end	
		end
	end	
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) and J.IsAllowedToSpam(bot, manaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(castRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, 0, 0 );
		local unitCount = X.CountVulnerableUnit(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(target) and J.CanCastOnNonMagicImmune(target) and J.IsInRange(target, bot, castRange) 
		then
			return BOT_ACTION_DESIRE_HIGH, X.GetProperLocation( target, (GetUnitToUnitDistance(bot, target)/nSpeed)+castPoint );
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function X.GetProperCastRange(bIgnore, hUnit, ability)
	local abilityCR = ability:GetCastRange();
	local attackRng = hUnit:GetAttackRange();
	if bIgnore then
		return abilityCR;
	elseif abilityCR <= attackRng then
		return attackRng + 200;
	elseif abilityCR + 200 <= 1600 then
		return abilityCR + 200;
	elseif abilityCR > 1600 then
		return 200;
	end
end

function X.CountVulnerableUnit(tUnits, locAOE, nRadius, nUnits)
	local count = 0;
	if locAOE.count >= nUnits then
		for _,unit in pairs(tUnits)
		do
			if GetUnitToLocationDistance(unit, locAOE.targetloc) <= nRadius and not unit:IsInvulnerable() then
				count = count + 1;
			end
		end
	end
	return count;
end

function X.GetLowestHPUnit(tUnits, bIgnoreImmune)
	local lowestHP   = 100000;
	local lowestUnit = nil; 
	for _,unit in pairs(tUnits)
	do
		local hp = unit:GetHealth()
		if hp < lowestHP and ( bIgnoreImmune or ( not bNotMagicImmune and not unit:IsMagicImmune() ) ) then
			lowestHP   = hp;
			lowestUnit = unit;
		end
	end
	return lowestUnit;
end

function X.GetProperLocation(hUnit, nDelay)
	if hUnit:GetMovementDirectionStability() >= 0 then
		return hUnit:GetExtrapolatedLocation(nDelay);
	end
	return hUnit:GetLocation();
end

return X;
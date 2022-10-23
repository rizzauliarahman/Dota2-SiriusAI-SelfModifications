-----------------
--英雄：兽王
--技能：野性之斧
--键位：Q
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('beastmaster_wild_axes')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 250 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--是否拥有蓝杖
abilityAhg = J.IsItemAvailable("item_ultimate_scepter"); 

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
    
	local nCastRange = GetProperCastRange(false, bot, ability:GetCastRange());
	local nCastPoint = ability:GetCastPoint();
	local manaCost  = ability:GetManaCost();
	local nRadius   = ability:GetSpecialValueInt( "radius" );
	
	if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = J.GetVulnerableWeakestUnit(bot, true, true, nCastRange-100);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = J.GetVulnerableUnitNearLoc(bot, true, true, nCastRange, nRadius, locationAoE.targetloc);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) and CanSpamSpell(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			local target = J.GetVulnerableUnitNearLoc(bot, false, true, nCastRange, nRadius, locationAoE.targetloc);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) and J.CanCastOnNonMagicImmune(target) and J.IsInRange(target, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
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

return X;
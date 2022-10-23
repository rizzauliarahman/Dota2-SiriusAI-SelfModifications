-----------------
--英雄：风行者
--技能：集中火力
--键位：R
--类型：指向单位
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('windrunner_focusfire')
local ability3 = bot:GetAbilityByName('windrunner_windrun')
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

    local nCastRange    = GetProperCastRange(false, bot, ability:GetCastRange());
	local nBonusAttackSpeed = ability:GetSpecialValueInt('bonus_attack_speed');
	local nDamageReduction = ability:GetSpecialValueInt('focusfire_damage_reduction');
	local nDamage = bot:GetAttackDamage();
	
	if ( J.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(3.0) 
		and  ( CanBeCast(ability3) == true or bot:HasModifier('modifier_windrunner_windrun') ) )
	then
		local enemies = bot:GetNearbyHeroes(0.65*nCastRange, true, BOT_MODE_NONE);
		for i=1, #enemies do
			if J.IsValidHero(enemies[i])
				and J.CanCastOnMagicImmune(enemies[i])
				and enemies[i]:GetAttackRange() < 325
				and ( enemies[i]:GetAttackTarget() == bot or enemies[i]:GetTarget() == bot
				or enemies[i]:IsFacingLocation(bot:GetLocation(), 10) )
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i];
			end	
		end
	end
	
	if J.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(bot, target, nCastRange) 
			and target:GetHealth() > 0.25*target:GetMaxHealth() 
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function CanBeCast(ability)
	return ability:IsTrained() and ability:IsFullyCastable() and ability:IsHidden() == false;
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

return X;
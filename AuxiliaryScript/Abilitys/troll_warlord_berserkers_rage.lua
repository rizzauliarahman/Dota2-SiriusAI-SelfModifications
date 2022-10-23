-----------------
--英雄：巨魔战将
--技能：狂战士之怒
--键位：Q
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('troll_warlord_berserkers_rage')
local abilityPC = bot:GetAbilityByName('troll_warlord_whirling_axes_melee')
local abilityPC2 = bot:GetAbilityByName('troll_warlord_whirling_axes_ranged')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

local toggleTime = DotaTime();

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
	X.Compensation() 
	toggleTime = DotaTime();
    bot:ActionQueue_UseAbility( ability ) --使用技能
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
	   or DotaTime() <= toggleTime + 0.2
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

    --WARStatus true = melee form, otherwise = range form
	local inMelee = false;
	if bot:GetAttackRange() < 320 then
		inMelee = true;
	end

	-- Get some of its values
	local nCastRange = 500;
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if ( bot:GetActiveMode() == BOT_MODE_LANING ) then
		local longestAR = 0;
		for _,enemy in pairs(tableNearbyEnemyHeroes)
		do
			local enemyAR = enemy:GetAttackRange();
			if enemyAR > longestAR then
				longestAR = enemyAR;
			end
		end
		if longestAR < 320 and not inMelee then
			return BOT_ACTION_DESIRE_MODERATE;
		elseif longestAR > 320 and inMelee then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		if #tableNearbyEnemyHeroes > 0 and abilityPC2:IsFullyCastable() and inMelee then
			-- print("cond 9")	
			return BOT_ACTION_DESIRE_MODERATE;
		elseif not abilityPC2:IsFullyCastable() and not inMelee then   	
			-- print("cond 10")
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	if J.IsPushing(bot)
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1 and inMelee then
			-- print("cond 6")
			return BOT_ACTION_DESIRE_MODERATE;
		elseif 	tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes < 1 and not inMelee then
			-- print("cond 7")
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot) 
	then
		local npcTarget = bot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			local Dist = GetUnitToUnitDistance(npcTarget, bot);
			if ( J.IsDisabled(npcTarget) or npcTarget:IsChanneling() 
				or bot:HasModifier('modifier_troll_warlord_battle_trance')
				or npcTarget:GetCurrentMovementSpeed() < bot:GetCurrentMovementSpeed() ) and Dist < 1000  	
			then
				if inMelee and abilityPC2:IsFullyCastable() then
					-- print("cond 1")
					return BOT_ACTION_DESIRE_MODERATE;	
				elseif not inMelee and abilityPC2:IsFullyCastable() == false then
					-- print("cond 2")
					return BOT_ACTION_DESIRE_MODERATE;
				end
			else
				if Dist > nCastRange + 200 and not inMelee then
					-- print("cond 3")
					return BOT_ACTION_DESIRE_MODERATE;
				elseif Dist > nCastRange / 2 + 175 and Dist < nCastRange + 200 and inMelee then
					-- print("cond 4")
					return BOT_ACTION_DESIRE_MODERATE;
				elseif Dist < nCastRange / 2 + 175 and not inMelee then
					-- print("cond 5")
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	
	
	if #tableNearbyEnemyHeroes == 0 and not inMelee then
		-- print("cond 8")
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;
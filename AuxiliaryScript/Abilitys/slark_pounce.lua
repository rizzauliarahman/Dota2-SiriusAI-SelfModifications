-----------------
--英雄：斯拉克
--技能：突袭
--键位：W
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('slark_pounce')
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
    X.Compensation() 
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
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

    -- Get some of its values
	local nCastRange = ability:GetSpecialValueInt( "pounce_distance" );
	local nDamage = 0;

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) )
		then
			local loc = J.GetEscapeLoc();
			if bot:IsFacingLocation(loc, 15) then
				local nFacing = 0;
				local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
				for i=1, #enemies do
					if J.IsValidHero(enemies[i]) 
						and J.CanCastOnNonMagicImmune(enemies[i]) 
						and U.IsFacingUnit(bot, enemies[i], 10) 
					then
						nFacing = nFacing + 1;
					end	
				end
				if nFacing == 0 then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange-200)
		   and U.IsFacingUnit(bot, npcTarget, 5) and not J.IsDisabled(npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;
-----------------
--英雄：噬魂鬼
--技能：狂暴
--键位：Q
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('life_stealer_rage')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
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

    --------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsUsingAbility() )  
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or npcEnemy:IsUsingAbility() or bot:GetHealth()/bot:GetMaxHealth() <= 0.15 ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	if ( bot:GetActiveMode() == BOT_MODE_FARM and bot:GetHealth()/bot:GetMaxHealth() < 0.65  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if npcTarget ~= nil 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, 300)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) 
		then
			local tDist =  GetUnitToUnitDistance( bot, npcTarget );
			local eHeroesCastSpell = false;
			local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcEnemy:IsUsingAbility() ) 
				then
					eHeroesCastSpell = true;
				end
			end
			if ( tDist < 300 or ( tDist < 500 and ( eHeroesCastSpell or npcTarget:IsUsingAbility() ) ) )
			then
				return BOT_ACTION_DESIRE_ABSOLUTE;
			end
		end
	end
    
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;
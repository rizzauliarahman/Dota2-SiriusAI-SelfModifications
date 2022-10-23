-----------------
--英雄：噬魂鬼
--技能：感染
--键位：R
--类型：指向目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('life_stealer_infest')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 120 --魔法储量
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
		
	-- Get some of its values
	local nCastRange = ability:GetCastRange();
	local nDamage = ability:GetSpecialValueInt("damage");
	local nRadius = ability:GetSpecialValueInt("radius");
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) 
		then
				local tableNearbyAlliedHeroes = bot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
				local tableNearbyAlliedCreeps = bot:GetNearbyLaneCreeps ( 800, false );
				local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps ( 800, true );
				for _,npcAllied in pairs( tableNearbyAlliedHeroes  )
				do
					if ( npcAllied:GetUnitName() ~= bot:GetUnitName() and J.CanCastOnNonMagicImmune(npcAllied) and J.IsInRange(npcAllied, bot, 3*nCastRange) ) 
					then
						return BOT_ACTION_DESIRE_HIGH, npcAllied;
					end
				end
			
				for _,npcACreep in pairs( tableNearbyAlliedCreeps  )
				do
					if J.CanCastOnNonMagicImmune(npcACreep) and J.IsInRange(npcACreep, bot, 3*nCastRange)
					then
						return BOT_ACTION_DESIRE_HIGH, npcACreep;
					end
				end
		
				for _,npcECreep in pairs( tableNearbyEnemyCreeps  )
				do
					if J.CanCastOnNonMagicImmune(npcECreep) and J.IsInRange(npcECreep, bot, 3*nCastRange)
					then
						return BOT_ACTION_DESIRE_HIGH, npcECreep;
					end
				end
		end
	end

	local npcTarget = bot:GetTarget();
	if J.IsValidHero(npcTarget) and J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and J.IsInRange(npcTarget, bot, nRadius-200)
	then
		local tableNearbyAlliedCreeps = bot:GetNearbyLaneCreeps ( 800, false );
			local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps ( 800, true );
		for _,npcACreep in pairs( tableNearbyAlliedCreeps  )
		do
			if J.CanCastOnNonMagicImmune(npcACreep) and J.IsInRange(npcACreep, npcTarget, nRadius-200)
			then
				return BOT_ACTION_DESIRE_HIGH, npcACreep;
			end
		end
		for _,npcECreep in pairs( tableNearbyEnemyCreeps  )
		do
			if J.CanCastOnNonMagicImmune(npcECreep) and J.IsInRange(npcECreep, npcTarget, nRadius-200)
			then
				return BOT_ACTION_DESIRE_HIGH, npcECreep;
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot) 
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and not J.IsInRange(npcTarget, bot,2000)
		then
			local tableNearbyAlliedHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			local target = nil;
			for _,npcAllied in pairs( tableNearbyAlliedHeroes  )
			do
				if ( npcAllied:GetUnitName() ~= bot:GetUnitName() and npcAllied:GetAttackRange() < 320 ) 
				then
					target = npcAllied;
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;
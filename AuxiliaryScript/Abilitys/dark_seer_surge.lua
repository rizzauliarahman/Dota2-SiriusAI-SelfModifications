-----------------
--英雄：黑暗贤者
--技能：奔腾
--键位：E
--类型：指向目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('dark_seer_surge')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 250 --魔法储量
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
	
	local nCastRange = ability:GetCastRange();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
	end
	
	local tableNearbyFriendlyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
		if J.IsRetreating(myFriend) and myFriend:WasRecentlyDamagedByAnyHero(2.0)
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, 1000)
		then
			local ClosestDist = GetUnitToUnitDistance(npcTarget, bot);
			local ClosestBot = bot; 
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				local dist = GetUnitToUnitDistance(npcTarget, myFriend);
				if dist < ClosestDist and dist < nCastRange then
					ClosestDist = dist;
					ClosestBot = myFriend;
				end
			end	
			return BOT_ACTION_DESIRE_MODERATE, ClosestBot;
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;
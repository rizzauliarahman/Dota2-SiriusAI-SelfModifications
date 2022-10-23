-----------------
--英雄：艾欧
--技能：过载
--键位：E
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('wisp_overcharge')
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

    local tetheredAlly = nil; 
	
	local NearbyAttackingAllies = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	for _,ally in pairs(NearbyAttackingAllies)
	do
		if ally:HasModifier('modifier_wisp_tether') then
			tetheredAlly = ally
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	if bot:GetActiveMode() == BOT_MODE_ATTACK and tetheredAlly ~= nil and bot:HasModifier('modifier_wisp_tether') then
		local npcTarget = bot:GetTarget();
		local allyAttackRange = tetheredAlly:GetAttackRange();
		local nAttackRange = bot:GetAttackRange();
		if npcTarget ~= nil and npcTarget:IsHero() and 
			( GetUnitToUnitDistance(npcTarget ,tetheredAlly) <= allyAttackRange or  GetUnitToUnitDistance(npcTarget ,bot) <= nAttackRange )
		then
			return BOT_ACTION_DESIRE_MODERATE
		end	
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;
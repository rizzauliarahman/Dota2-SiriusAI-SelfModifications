-----------------
--英雄：酒仙
--技能：醉拳
--键位：R
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('brewmaster_primal_split')
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

    local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	if #tableNearbyAllyHeroes == 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local distance = 300;
	
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if J.IsInTeamFight(bot, 1200) and not ability:IsFullyCastable()
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot) and not ability:IsFullyCastable()
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, 400) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			local tableNearbyAlly = bot:GetNearbyHeroes( 1200, false, BOT_MODE_ATTACK );
			if tableNearbyEnemyHeroes ~= nil and tableNearbyAlly ~= nil and #tableNearbyEnemyHeroes >= 2 and #tableNearbyAlly >= 2 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;
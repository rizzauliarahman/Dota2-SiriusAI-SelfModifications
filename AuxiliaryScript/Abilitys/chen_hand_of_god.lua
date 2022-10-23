-----------------
--英雄：陈
--技能：上帝之手
--键位：R
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('chen_hand_of_god')
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

    if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local Allies=bot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if  Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes > 0 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	local numPlayer =  GetTeamPlayers(GetTeam());
	local maxDist = 0;
	local target = nil;
	for i = 1, #numPlayer
	do
		local Ally = GetTeamMember(i);
		if Ally:IsAlive() and 
			Ally:GetActiveMode() == BOT_MODE_RETREAT and Ally:GetActiveModeDesire() >= BOT_ACTION_DESIRE_HIGH and
			Ally:GetHealth() /Ally:GetMaxHealth() < 0.45 and Ally:WasRecentlyDamagedByAnyHero(2.0)
		then
			target = GetTeamMember(i);
			break;
		end
	end
	if target ~= nil then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;
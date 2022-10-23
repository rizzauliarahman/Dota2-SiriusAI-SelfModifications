-----------------
--英雄：风暴之灵
--技能：球状闪电
--键位：R
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('storm_spirit_ball_lightning')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 400 --魔法储量
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
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	
	-- Get some of its values
	local nCastPoint = ability:GetCastPoint( );
	local nInitialMana = ability:GetSpecialValueInt("ball_lightning_initial_mana_base")
	local nInitialManaP = ability:GetSpecialValueInt("ball_lightning_initial_mana_percentage") / 100
	local nTravelCost = ability:GetSpecialValueInt("ball_lightning_travel_cost_base")
	local nTravelCostP = ability:GetSpecialValueFloat("ball_lightning_travel_cost_percent") / 100

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, 600);
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) )
		then
			local loc = J.GetEscapeLoc();
		    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, 600);
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and not J.IsInRange(npcTarget, bot, bot:GetAttackRange()-200) and  J.IsInRange(npcTarget, bot, 1600)   
		then
			local MaxMana = bot:GetMaxMana();
			local distance = GetUnitToUnitDistance( npcTarget, bot );
			local tableNearbyAllyHeroes = npcTarget:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
			local TotalInitMana = nInitialMana + ( nInitialManaP * MaxMana );
			local TotalTravelMana = ( nTravelCost * ( distance / 100 ) ) + ( nTravelCostP * MaxMana * ( distance / 100 ) );
			local TotalMana = TotalInitMana + TotalTravelMana;
			--print(TotalMana)
			if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 and X.BallLightningAllowed( TotalMana ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( 2*nCastPoint );
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.BallLightningAllowed(manaCost)
	if ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= 0.20
	then
		return true
	end
	return false
end

return X;
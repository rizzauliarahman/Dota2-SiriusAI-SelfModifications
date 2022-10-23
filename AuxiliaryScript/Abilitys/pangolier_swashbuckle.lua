-----------------
--英雄：石鳞剑士
--技能：虚张声势
--键位：Q
--类型：指向地点
--作者：Krizalium
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('pangolier_swashbuckle')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 500 --魔法储量
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
	   or bot:HasModifier("modifier_pangolier_gyroshell")
	   or bot:HasModifier('modifier_pangolier_swashbuckle_stunned') 
	   or bot:IsRooted()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nCastRange = X.GetProperCastRange(false, bot, ability:GetCastRange());
	local nCastPoint = ability:GetCastPoint();
	local manaCost  = ability:GetManaCost();
	local nRadius   = ability:GetSpecialValueInt( "start_radius" );
	
	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange );
	end
	
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:WasRecentlyDamagedByTower(2.0) or #tableNearbyEnemyHeroes > 1 )
		then
			local loc = J.GetEscapeLoc();
		    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange );
		end	
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange) 
		then
			local tableNearbyEnemies = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			local tableNearbyAllies = npcTarget:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
			if #tableNearbyEnemies <= #tableNearbyAllies then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.GetProperCastRange(bIgnore, hUnit, abilityCR)
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
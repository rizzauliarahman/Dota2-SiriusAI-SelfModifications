-----------------
--英雄：凤凰
--技能：凤凰冲击
--键位：Q
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('phoenix_icarus_dive')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 250 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友
if bot.everStuck == nil then bot.everStuck = false end
if bot.EscLoc == nil then bot.EscLoc = {} end

--是否拥有蓝杖
abilityAhg = J.IsItemAvailable("item_ultimate_scepter"); 

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
	if castTarget ~= nil then
		bot.EscLoc = castIDLocation;
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
	   or ability:IsHidden()
	   or bot:HasModifier("modifier_phoenix_icarus_dive")
	   or bot:IsRooted()
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
	local nCastRange = ability:GetSpecialValueInt("dash_length");
	local nRadius = ability:GetSpecialValueInt( "dash_width" );
	local nCastPoint = ability:GetCastPoint();
	local nDamage = ability:GetSpecialValueInt("damage_per_second") * ability:GetSpecialValueFloat("burn_duration");
	
	if J.IsStuck(bot)
	then
		bot.everStuck = true;
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), nCastRange );
	end
	
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, GetTowardsFountainLocation(bot:GetLocation(), nCastRange);
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1000, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if (  J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, ( nCastRange / 2 ) + 200 ) )
		then
			local eta = ( GetUnitToUnitDistance( npcTarget, bot ) / 1000 ) + nCastPoint;
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( eta );
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function GetTowardsFountainLocation( unitLoc, distance )
	local destination = {}
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt( 2 )
		destination[2] = unitLoc[2] - distance / math.sqrt( 2 )
	end

	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt( 2 )
		destination[2] = unitLoc[2] + distance / math.sqrt( 2 )
	end
	return Vector( destination[1], destination[2] )
end

return X;
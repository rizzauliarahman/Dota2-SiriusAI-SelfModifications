-----------------
--英雄：上古巨神
--技能：裂地沟壑
--键位：R
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('elder_titan_earth_splitter')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 110 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

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
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
	-- Get some of its values
	local nRadius = ability:GetSpecialValueInt("crack_width");
	local nCastRange = ability:GetCastRange();
	local nCastPoint = ability:GetCastPoint();
	local nPercentageHP = ability:GetSpecialValueInt("damage_pct");
	local nCrackTime = ability:GetSpecialValueInt("crack_time");

	--------------------------------------
	-- Mode based usage
	--------------------------------------	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nCastPoint + nCrackTime - 1.5 );
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1000, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local nInvUnit = FindNumInvUnitInLoc(false, bot, 1200, nRadius, locationAoE.targetloc);
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, 1000)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			local nInvUnit = CountInvUnits(true, tableNearbyEnemyHeroes);
			if nInvUnit >= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint + nCrackTime - 1.5 );
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function CountInvUnits(pierceImmune, units)
	local nUnits = 0;
	if units ~= nil then
		for _,u in pairs(units) do
			if ( pierceImmune and J.CanCastOnMagicImmune(u) ) or ( not pierceImmune and J.CanCastOnNonMagicImmune(u) )  then
				nUnits = nUnits + 1;
			end
		end
	end
	return nUnits;
end

function FindNumInvUnitInLoc(pierceImmune, bot, nRange, nRadius, loc)
	local nUnits = 0;
	if nRange > 1600 then nRange = 1600 end
	local units = bot:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	for _,u in pairs(units) do
		if ( ( pierceImmune and J.CanCastOnMagicImmune(u) ) or ( not pierceImmune and J.CanCastOnNonMagicImmune(u) ) ) and GetUnitToLocationDistance(u, loc) <= nRadius then
			nUnits = nUnits + 1;
		end
	end
	return nUnits;
end

return X;
-----------------
--英雄：巨牙海民
--技能：寒冰碎片
--键位：Q
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('tusk_ice_shards')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 300 --魔法储量
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
	local nRadius = ability:GetSpecialValueInt( "shard_width" );
	local nCastRange = 1600;
	local nCastPoint = ability:GetCastPoint( );
	local nDamage = ability:GetSpecialValueInt("shard_damage");
	local nSpeed = ability:GetSpecialValueInt("shard_speed");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( ((GetUnitToUnitDistance(npcEnemy, bot)+200)/nSpeed) + nCastPoint );
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if J.IsDefending(bot) or J.IsPushing(bot)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and bot:GetMana()/bot:GetMaxMana() > 0.65 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end

	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)  
		then
			local dist =  GetUnitToUnitDistance(bot, npcTarget);
			return BOT_ACTION_DESIRE_MODERATE, J.Site.GetXUnitsTowardsLocation( bot, npcTarget:GetLocation(), dist + (dist/nSpeed+nCastPoint)*200);
			--return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( ((GetUnitToUnitDistance(npcTarget, bot)+200)/nSpeed) + nCastPoint );
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;
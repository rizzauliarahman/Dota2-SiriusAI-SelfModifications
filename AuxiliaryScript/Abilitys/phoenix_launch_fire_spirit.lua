-----------------
--英雄：凤凰
--技能：发动烈火精灵
--键位：W
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('phoenix_launch_fire_spirit')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;
local spiritCT = 0.0;

nKeepMana = 250 --魔法储量
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
	if castTarget ~= nil and DotaTime() >= spiritCT + castTarget['FSETA'] + 0.25 then
        X.Compensation()
		bot:ActionQueue_UseAbilityOnLocation( ability, castTarget['Target'] ) --使用技能
		spiritCT = DotaTime();
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
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
	local nCastRange = ability:GetCastRange();
	local nRadius = ability:GetSpecialValueInt( "radius" );
	local nCastPoint = ability:GetCastPoint();
	local nDamage = ability:GetSpecialValueInt("damage_per_second") * ability:GetSpecialValueFloat("duration");
	local nSpeed = ability:GetSpecialValueInt("spirit_speed");
	
	if nCastRange > 1600 then nCastRange = 1600 end
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );

	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,enemy in pairs(tableNearbyEnemyHeroes)
		do
			if J.CanCastOnNonMagicImmune(enemy) and  not enemy:HasModifier("modifier_phoenix_fire_spirit_burn") then
				local eta = ( GetUnitToUnitDistance(enemy, bot) / nSpeed ) + nCastPoint ;
				return  BOT_ACTION_DESIRE_MODERATE, {
					['Target'] = enemy:GetExtrapolatedLocation(eta),
					['FSETA'] = eta,
				};
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,enemy in pairs(tableNearbyEnemyHeroes)
		do
			if J.CanCastOnNonMagicImmune(enemy) and not enemy:HasModifier("modifier_phoenix_fire_spirit_burn") then
				local eta = ( GetUnitToUnitDistance(enemy, bot) / nSpeed ) + nCastPoint ;
				return  BOT_ACTION_DESIRE_MODERATE, {
					['Target'] = enemy:GetExtrapolatedLocation(eta),
					['FSETA'] = eta,
				};
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange( npcTarget, bot, nCastRange )
			 and not npcTarget:HasModifier("modifier_phoenix_fire_spirit_burn") ) 
		then
			local eta = ( GetUnitToUnitDistance( npcTarget, bot ) / nSpeed ) + nCastPoint;
			return BOT_ACTION_DESIRE_MODERATE, {
				['Target'] = npcTarget:GetExtrapolatedLocation( eta ),
				['FSETA'] = eta,
			};
		end
	end
	
	if tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0 then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local eta = ( GetUnitToLocationDistance(bot, locationAoE.targetloc) / nSpeed ) + nCastPoint ;
			return BOT_ACTION_DESIRE_MODERATE, {
				['Target'] = locationAoE.targetloc,
				['FSETA'] = eta,
			};
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end


return X;
-----------------
--英雄：凤凰
--技能：超新星
--键位：R
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('phoenix_ability')
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
	X.Compensation()
	if castTarget == nil then
		bot:Action_UseAbility( ability )
		return;
	else
		bot:Action_UseAbilityOnEntity( ability, castTarget )
		return;
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
	   or bot:HasModifier("modifier_phoenix_ability_hiding")
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	local nCastRange = ability:GetSpecialValueInt('cast_range_tooltip_scepter');
	local nRadius = ability:GetSpecialValueInt( "aura_radius" );
	local nCastPoint = ability:GetCastPoint();
	local nDamage = ability:GetSpecialValueInt("damage_per_sec") * ability:GetSpecialValueInt("tooltip_duration");
	
	if bot:HasScepter() and J.IsInTeamFight(bot, 1200) then
		local tableNearbyAllyHeroes = bot:GetNearbyHeroes( nCastRange + 200, false, BOT_MODE_NONE );
		for _,ally in pairs(tableNearbyAllyHeroes)
		do
			if ( ally:GetActiveMode() == BOT_MODE_RETREAT or ally:GetHealth()/ally:GetMaxHealth() < 0.25 ) and ally:WasRecentlyDamagedByAnyHero(2.0) then
				return BOT_ACTION_DESIRE_HIGH, ally;
			end	
		end
	end
	
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes =  bot:GetNearbyHeroes( nRadius, false, BOT_MODE_ATTACK );
		local ASSlowedNum = 0;
		for _,npcEnemy in pairs(tableNearbyEnemyHeroes) 
		do
			if npcEnemy:HasModifier('modifier_phoenix_fire_spirit_burn') then
				ASSlowedNum = ASSlowedNum + 1;
			end
		end
		
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and ( #tableNearbyEnemyHeroes - ASSlowedNum ) <= 1 then
			return BOT_ACTION_DESIRE_HIGH, "";
		end
		
		if bot:WasRecentlyDamagedByAnyHero(2.0) and #tableNearbyAllyHeroes >= 2 and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_HIGH, "";
		end
	end
	
	
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( (nRadius / 2) + 200, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 then
			return BOT_ACTION_DESIRE_HIGH, "";
		end	
	end
    
	return BOT_ACTION_DESIRE_NONE, nil;

end

return X;
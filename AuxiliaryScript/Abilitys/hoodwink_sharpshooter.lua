-----------------
--英雄：林海飞霞
--技能：一箭穿心
--键位：R
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('hoodwink_sharpshooter')
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
    
	local nCastPoint = ability:GetCastPoint();
	local manaCost   = ability:GetManaCost();
	local nRadius    = ability:GetSpecialValueInt('arrow_width');
	local speed    = ability:GetSpecialValueInt('arrow_speed');
	local nCastRange    = 1600;
	local nCastRange2    = ability:GetSpecialValueInt('arrow_range');
	local nAttackRange    = bot:GetAttackRange();
	
	if ( J.IsDefending(bot) ) and  CanSpamSpell(manaCost) 
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1, #enemies do
			if J.IsValidHero(enemies[i]) 
				and J.CanCastOnNonMagicImmune(enemies[i]) == true
				and J.IsInRange(bot, enemies[i], 0.5*nCastRange) == false 
				and J.IsInRange(bot, enemies[i], nCastRange) == true 
			then	
				return BOT_ACTION_DESIRE_MODERATE, enemies[i]:GetLocation();
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 and GetUnitToLocationDistance(bot,  locationAoE.targetloc) > 0.5*nAttackRange ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	if J.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(bot, target, nAttackRange) == false
			and J.IsInRange(bot, target, nCastRange2) == true
		then
			local distance = GetUnitToUnitDistance(target, bot)
			local moveCon = target:GetMovementDirectionStability();
			local pLoc = target:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			if moveCon < 0.95 then
				pLoc = target:GetLocation();
			end
			return BOT_ACTION_DESIRE_MODERATE, pLoc;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function CanSpamSpell(manaCost)
	local initialRatio = 1.0;
	if manaCost < 100 then
		initialRatio = 0.6;
	end
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( initialRatio - bot:GetLevel()/(2*25) );
end

return X;
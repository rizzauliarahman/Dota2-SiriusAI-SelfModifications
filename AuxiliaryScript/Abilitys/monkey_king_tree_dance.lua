-----------------
--英雄：齐天大圣
--技能：丛林之舞
--键位：W
--类型：指向目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('monkey_king_tree_dance')
local abilityWC = bot:GetAbilityByName('monkey_king_wukongs_command')
local abilityPS = bot:GetAbilityByName('monkey_king_primal_spring')

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
        bot:ActionQueue_UseAbilityOnTree( ability, castTarget ) --使用技能
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
	
	local nCastRange = ability:GetCastRange();
	local nRadius = abilityWC:GetSpecialValueInt("second_radius");
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	if tableNearbyEnemyHeroes == nil then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( not abilityPS:IsFullyCastable() and not abilityPS:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if J.IsRetreating(bot) and abilityPS:IsFullyCastable() and bot:DistanceFromFountain() > 1000 and #tableNearbyEnemyHeroes >= 1
	then
		local tableNearbyTrees = bot:GetNearbyTrees( nCastRange );
		local furthest = GetFurthestTree(tableNearbyTrees);
		if furthest ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, furthest;
		end
	end

	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange) ) 
		then
			local tableNearbyTrees = npcTarget:GetNearbyTrees( nCastRange );
			if tableNearbyTrees ~= nil 
				and #tableNearbyTrees >= 1 
			then
				if bot:HasModifier('modifier_monkey_king_fur_army_bonus_damage') == false 
					or bot.WCLoc == nil
					or ( bot:HasModifier('modifier_monkey_king_fur_army_bonus_damage') == true and J.Site.GetDistance(GetTreeLocation(tableNearbyTrees[1]), bot.WCLoc) < 0.90*nRadius )
				then	
					return BOT_ACTION_DESIRE_MODERATE, tableNearbyTrees[1];
				end
			end
		end
	end 
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function GetFurthestTree(trees)
	if Ancient == nil then return nil end; 
	local furthest = nil;
	local fDist = 10000;
	for _,tree in pairs(trees)
	do
		local dist = GetUnitToLocationDistance(Ancient, GetTreeLocation(tree));
		if dist < fDist then
			furthest = tree;
			fDist = dist;
		end
	end
	return furthest;
end

return X;
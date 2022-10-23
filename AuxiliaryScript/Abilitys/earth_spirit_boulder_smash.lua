-----------------
--英雄：大地之灵
--技能：巨石冲击
--键位：Q
--类型：指向目标、地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('earth_spirit_boulder_smash')
local abilityD = bot:GetAbilityByName('earth_spirit_stone_caller')

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, devourAnciennt, nStone;

nStone = 0;

if devourAnciennt == nil then devourAnciennt = bot:GetAbilityByName( "special_bonus_unique_doom_2" ) end

nKeepMana = 180 --魔法储量
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
        if castTarget.castStone then
			bot:Action_ClearActions(false);
			bot:ActionQueue_UseAbilityOnLocation(abilityD, bot:GetLocation());
			bot:ActionQueue_UseAbilityOnLocation(ability, castTarget.Target);
			return;
		else
			if castTarget.stoneNear then
				bot:Action_UseAbilityOnLocation( ability, castTarget.Target );
				return;
			else
				bot:Action_UseAbilityOnEntity( ability, castTarget.Target );
				return;
			end
        end
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
		return BOT_ACTION_DESIRE_NONE, {
            ['Target'] = 0,
            ['castStone'] = false,
            ['stoneNear'] = false,
        }; --没欲望
	end
	
	if abilityD:IsFullyCastable() then
		nStone = 1;
	else
		nStone = 0;
	end

	-- Get some of its values
	local nRadius     = ability:GetSpecialValueInt('radius');
	local nSearchRad  = ability:GetSpecialValueInt('rock_search_aoe');
	local nUnitCR     = 150;
	local nStoneCR    = ability:GetSpecialValueInt('rock_distance');
	local nCastPoint  = ability:GetCastPoint( );
	local nManaCost   = ability:GetManaCost( );
	local nSpeed      = ability:GetSpecialValueInt('speed');
	local nDamage     = ability:GetSpecialValueInt('rock_damage');

	if nStoneCR > 1600 then nStoneCR = 1300 end
	
	local stoneNearby = IsStoneNearby(bot:GetLocation(), nSearchRad);
	
	--if we can kill any enemies
	if stoneNearby then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nStoneCR, true, BOT_MODE_NONE );
		local target = GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
		if target ~= nil then
			local loc = J.GetCorrectLoc(target, GetUnitToUnitDistance(bot, target)/nSpeed)
			return BOT_ACTION_DESIRE_HIGH, {
                ['Target'] = loc,
                ['castStone'] = false,
                ['stoneNear'] = true,
            }; 
		end
	elseif nStone >= 1 then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nStoneCR, true, BOT_MODE_NONE );
		local target = GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
		if target ~= nil then
			local loc = J.GetCorrectLoc(target, GetUnitToUnitDistance(bot, target)/nSpeed)
			return BOT_ACTION_DESIRE_HIGH, {
                ['Target'] = loc,
                ['castStone'] = true,
                ['stoneNear'] = false,
            }; 
		end
	elseif nStone < 1 then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nUnitCR+200, true, BOT_MODE_NONE );
		local target = GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, {
                ['Target'] = target,
                ['castStone'] = false,
                ['stoneNear'] = false,
            }; 
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero( 1.0 )
	then
		if stoneNearby then
			local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nStone, true, BOT_MODE_NONE );
			local target = GetClosestUnit(tableNearbyEnemyHeroes)
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, {
                    ['Target'] = target:GetLocation(),
                    ['castStone'] = false,
                    ['stoneNear'] = true,
                }; 
			end
		elseif nStone >= 1 then
			local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nStone, true, BOT_MODE_NONE );
			local target = GetClosestUnit(tableNearbyEnemyHeroes)
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, {
                    ['Target'] = target:GetLocation(),
                    ['castStone'] = true,
                    ['stoneNear'] = false,
                }; 
			end
		elseif nStone < 1 then
			local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nUnitCR+200, true, BOT_MODE_NONE );
			local target = GetClosestUnit(tableNearbyEnemyHeroes)
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, {
                    ['Target'] = target,
                    ['castStone'] = false,
                    ['stoneNear'] = false,
                }; 
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200) 
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nStoneCR, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			if stoneNearby then
				return BOT_ACTION_DESIRE_LOW, {
                    ['Target'] = locationAoE.targetloc,
                    ['castStone'] = false,
                    ['stoneNear'] = true,
                };
			elseif nStone >= 1 then
				return BOT_ACTION_DESIRE_LOW, {
                    ['Target'] = locationAoE.targetloc,
                    ['castStone'] = true,
                    ['stoneNear'] = false,
                };
			end
		end
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot) 
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nStoneCR + 200) 
		then
			local loc = J.GetCorrectLoc(npcTarget, GetUnitToUnitDistance(bot, target)/nSpeed)
			if stoneNearby then
				return BOT_ACTION_DESIRE_HIGH, {
                    ['Target'] = loc,
                    ['castStone'] = false,
                    ['stoneNear'] = true,
                };
			elseif nStone >= 1 then
				return BOT_ACTION_DESIRE_HIGH, {
                    ['Target'] = loc,
                    ['castStone'] = true,
                    ['stoneNear'] = false,
                };
			end
		end
	end
	
	local skThere, skLoc = J.IsSandKingThere(bot, nStoneCR, 2.0);
	
	if skThere and nStone >= 1 then
		return BOT_ACTION_DESIRE_MODERATE, {
            ['Target'] = skLoc,
            ['castStone'] = true,
            ['stoneNear'] = false,
        };
	end
	
	return BOT_ACTION_DESIRE_NONE, {
        ['Target'] = 0,
        ['castStone'] = false,
        ['stoneNear'] = false,
    };
	
end

function IsStoneNearby(location, radius)
	local units = GetUnitList(UNIT_LIST_ALLIED_OTHER);
	for _,u in pairs(units) do
		if u ~= nil and u:GetUnitName() == "npc_dota_earth_spirit_stone" and GetUnitToLocationDistance(u, location) < radius then
			return true;
		end
	end
	return false;
end 

function GetCanBeKilledUnit(units, nDamage, nDmgType, magicImmune)
	local target = nil;
	for _,unit in pairs(units)
	do
		if ( ( magicImmune and J.CanCastOnMagicImmune(unit) ) or ( not magicImmune and J.CanCastOnNonMagicImmune(unit) ) ) 
			   and J.CanKillTarget(unit, nDamage, nDmgType) 
		then
			unitKO = target;	
		end
	end
	return target;
end

function GetClosestUnit(units)
	local target = nil;
	if units ~= nil and #units >= 1 then
		return units[1];
	end
	return target;
end

return X;
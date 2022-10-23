-----------------
--英雄：大地之灵
--技能：巨石翻滚
--键位：W
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('earth_spirit_rolling_boulder')
local abilityD = bot:GetAbilityByName('earth_spirit_stone_caller')

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, nStone;

nStone = 0;

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

        if castTarget.castStone then
			bot:Action_ClearActions(false);
			bot:ActionQueue_UseAbilityOnLocation(ability, castTarget.Target);
			bot:ActionQueue_UseAbilityOnLocation(abilityD, J.Site.GetXUnitsTowardsLocation( bot, castTarget.Target, 300));
			return;
		else
			bot:Action_UseAbilityOnLocation( ability, castTarget.Target);
			return;
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
            ['castStone'] = false
        }; --没欲望
	end
    
    if abilityD:IsFullyCastable() then
		nStone = 1;
	else
		nStone = 0;
    end
    
	-- Get some of its values
	local nRadius     = ability:GetSpecialValueInt('radius');
	local nUnitCR     = ability:GetSpecialValueInt('distance');
	local nStoneCR    = ability:GetSpecialValueInt('rock_distance');
	local nCastPoint  = ability:GetCastPoint( );
	local nDelay      = ability:GetSpecialValueFloat('delay');
	local nManaCost   = ability:GetManaCost( );
	local nSpeed      = ability:GetSpecialValueInt('speed');
	local nRSpeed     = ability:GetSpecialValueInt('rock_speed');
	local nDamage     = ability:GetSpecialValueInt('damage');
	
	if nStoneCR > 1600 then nStoneCR = 1300 end
	
	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, {
            ['Target'] = J.Site.GetXUnitsTowardsLocation( bot, loc, nStoneCR ),
            ['castStone'] = false
        };
	end
	
	--if we can kill any enemies
	if nStone >= 1 then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nStoneCR, true, BOT_MODE_NONE );
		local target = GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
		if target ~= nil then
			local loc = J.GetCorrectLoc(target, (GetUnitToUnitDistance(bot, target)/nRSpeed)+nDelay)
			if IsStoneInPath(loc, (nUnitCR/2)+200) then
				return BOT_ACTION_DESIRE_HIGH, {
                    ['Target'] = loc,
                    ['castStone'] = false
                }; 
			else
				return BOT_ACTION_DESIRE_HIGH, {
                    ['Target'] = loc,
                    ['castStone'] = true
                }; 
			end
		end
	elseif nStone < 1 then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nUnitCR-200, true, BOT_MODE_NONE );
		local target = GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, {
                ['Target'] = target,
                ['castStone'] = false
            }; 
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero( 1.0 )
	then
		local location = J.GetEscapeLoc();
		local loc = J.Site.GetXUnitsTowardsLocation( bot, location, nUnitCR );
		if IsStoneInPath(loc, (nUnitCR/2)+200) then
			return BOT_ACTION_DESIRE_MODERATE, {
                ['Target'] = loc,
                ['castStone'] = false
            };
		elseif nStone >= 1 then
			return BOT_ACTION_DESIRE_MODERATE, {
                ['Target'] = loc,
                ['castStone'] = true
            };
		elseif nStone < 1 then
			return BOT_ACTION_DESIRE_MODERATE, {
                ['Target'] = loc,
                ['castStone'] = false
            };
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot) 
	then
		local npcTarget = bot:GetTarget();
		if nStone >= 1 and J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nStoneCR + 200) 
		then
			local targetAlly  = npcTarget:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local targetEnemy = npcTarget:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			if targetEnemy ~= nil and targetAlly ~= nil and #targetEnemy >= #targetAlly then
				local loc = J.GetCorrectLoc(npcTarget, GetUnitToUnitDistance(bot, target)/nRSpeed)
				if IsStoneInPath(loc, (nUnitCR/2)+200) then
					return BOT_ACTION_DESIRE_HIGH, {
                        ['Target'] = loc,
                        ['castStone'] = false
                    };
				else
					return BOT_ACTION_DESIRE_HIGH, {
                        ['Target'] = loc,
                        ['castStone'] = true
                    };
				end
			end	
		elseif nStone < 1 and J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nUnitCR / 2)  then
			local loc = J.GetCorrectLoc(npcTarget, GetUnitToUnitDistance(bot, target)/nSpeed)
			return BOT_ACTION_DESIRE_HIGH, {
                ['Target'] = loc,
                ['castStone'] = false
            };
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, {
        ['Target'] = 0,
        ['castStone'] = false,
        ['stoneNear'] = false,
    };
	
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

function IsStoneInPath(location, dist)
	if bot:IsFacingLocation(location, 5) then
		local units = GetUnitList(UNIT_LIST_ALLIED_OTHER);
		for _,u in pairs(units) do
			if u ~= nil and u:GetUnitName() == "npc_dota_earth_spirit_stone" 
			   and bot:IsFacingLocation(u:GetLocation(), 5) and GetUnitToUnitDistance(u, bot) < dist 
			then
				return true;
			end
		end
	end
	return false;
end

return X;
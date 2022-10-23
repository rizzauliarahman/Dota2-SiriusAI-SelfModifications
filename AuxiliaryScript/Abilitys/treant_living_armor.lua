-----------------
--英雄：树精卫士
--技能：活体护甲
--键位：E
--类型：指向地点/单位
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('treant_living_armor')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

local checkBuildingTime = DotaTime();

local towers = { TOWER_TOP_1, TOWER_TOP_2, TOWER_TOP_3,
                   TOWER_MID_1, TOWER_MID_2, TOWER_MID_3,
                   TOWER_BOT_1, TOWER_BOT_2, TOWER_BOT_3,
                   TOWER_BASE_1, TOWER_BASE_2
				   }
local barracks = { BARRACKS_TOP_MELEE, BARRACKS_TOP_RANGED, 
					 BARRACKS_MID_MELEE, BARRACKS_MID_RANGED, 
					 BARRACKS_BOT_MELEE, BARRACKS_BOT_RANGED
					}

local team = GetTeam();

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
		local typeAOE = X.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT);
		if typeAOE == true then
			bot:Action_UseAbilityOnLocation( ability, castTarget:GetLocation() );
		else
			bot:Action_UseAbilityOnEntity( ability, castTarget );
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
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nCastRange = 1600;
	local total_heal = ability:GetSpecialValueInt('total_heal');
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) and bot:HasModifier('modifier_treant_living_armor') == false
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
	end

	-- If we're pushing or defending a lane
	if J.IsDefending(bot)
	then
		local tableNearbyFriendlyTowers = bot:GetNearbyTowers( 400, false );
		for _,myTower in pairs(tableNearbyFriendlyTowers) do
			if ( GetUnitToUnitDistance( myTower, bot  ) < 400 and myTower:HasModifier('modifier_treant_living_armor') == false ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myTower;
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyAllyHeroes = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcAlly in pairs( tableNearbyAllyHeroes )
		do
			if (  J.CanCastOnNonMagicImmune(npcAlly) and( npcAlly:GetHealth() / npcAlly:GetMaxHealth() ) < 0.5 and npcAlly:HasModifier('modifier_treant_living_armor') == false ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcAlly;
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot) and bot:HasModifier('modifier_treant_living_armor') == false
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and ( bot:GetHealth() / bot:GetMaxHealth() ) < 0.5  and J.IsInRange(npcTarget, bot, 600) 
		then
			return BOT_ACTION_DESIRE_MODERATE, bot;
		end
	end

	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local Player = GetTeamMember(i);
		if Player:IsAlive() and Player:HasModifier('modifier_treant_living_armor') == false and Player:GetHealth()/Player:GetMaxHealth() < 0.65 and 
		   J.IsRetreating(Player) and Player:DistanceFromFountain() > 0  
		then
			return BOT_ACTION_DESIRE_MODERATE, Player;
		end
	end
	
	local target_building = nil;
	if  DotaTime() > checkBuildingTime + 5.0 then
		target_building = GetTargetBuildingToHeal(total_heal);
		checkBuildingTime = DotaTime();
	end
	
	if target_building ~= nil then
		return  BOT_ACTION_DESIRE_HIGH, target_building;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1;
end

function GetTargetBuildingToHeal(total_heal)
	local target_building = nil;
	local min_hp = 10000;
	for i=1, #towers do
		local tower = GetTower(team, towers[i]);
		if tower ~= nil and tower:HasModifier('modifier_treant_living_armor') == false then
			local hp = tower:GetHealth();
			if hp < min_hp and hp + total_heal < tower:GetMaxHealth() then
				target_building = tower;
				min_hp = hp;
			end	
		end
	end
	for i=1, #barracks do
		local barrack = GetBarracks(team, barracks[i]);
		if barrack ~= nil and barrack:HasModifier('modifier_treant_living_armor') == false then
			local hp = barrack:GetHealth();
			if hp < min_hp and hp + total_heal < barrack:GetMaxHealth() then
				target_building = barrack;
				min_hp = hp;
			end	
		end
	end
	return target_building;
end

return X;
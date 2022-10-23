-----------------
--英雄：虚无之灵
--技能：残阴
--键位：Q
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('void_spirit_aether_remnant')
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

	local nCastRange = ability:GetCastRange();
	local nCastPoint = ability:GetCastPoint();
	local nSkillLV   = ability:GetLevel();

	local creeps = bot:GetNearbyCreeps(1000, true)
	local enemyHeroes = bot:GetNearbyHeroes(600, true, BOT_MODE_NONE)
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsMoving(npcEnemy)
				and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(1.0);
			end
		end
	end

	-- If we're going after someone
	local numPlayer = GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member = GetTeamMember(i);
		if J.IsValid(member)
		   and J.IsGoingOnSomeone(member)
		then
			local npcTarget = J.GetProperTarget(member);
			if J.IsValidHero(npcTarget) 
			   and J.IsRunning(npcTarget)
			   and J.IsInRange(npcTarget, bot, nCastRange + 800) 
			   and not J.IsInRange(npcTarget, bot, bot:GetAttackRange()) 
			   and J.CanCastOnNonMagicImmune(npcTarget) 
			then
				
				local targetFutureLoc = npcTarget:GetExtrapolatedLocation(1.8);
				if GetUnitToLocationDistance(bot,targetFutureLoc) <= nCastRange + 50
					and npcTarget:GetMovementDirectionStability() > 0.95
					and IsLocationPassable(targetFutureLoc)
				then
					return BOT_ACTION_DESIRE_HIGH, targetFutureLoc;
				end
				
				targetFutureLoc = npcTarget:GetExtrapolatedLocation(0.8);
				if GetUnitToLocationDistance(bot,targetFutureLoc) <= nCastRange + 50
				   and npcTarget:GetMovementDirectionStability() > 0.9
				   and IsLocationPassable(targetFutureLoc)
				then
					return BOT_ACTION_DESIRE_HIGH, targetFutureLoc;
				end
				
				local targetLoc = npcTarget:GetLocation();
				if GetUnitToLocationDistance(bot,targetLoc) <= nCastRange + 50
				then
					return BOT_ACTION_DESIRE_HIGH, targetLoc;
				end
				
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;
-----------------
--英雄：艾欧
--技能：羁绊
--键位：Q
--类型：指向目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('wisp_tether')
local abilityRC = bot:GetAbilityByName('wisp_relocate')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 180 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("wisp_tether");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    if castTarget ~= nil then
		X.Compensation()
		bot:ActionQueue_UseAbilityOnEntity( ability, castTarget )
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
	local nCastRange = ability:GetCastRange();
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can suicide
	if J.IsRetreating(bot) and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 
	then
		local numPlayer =  GetTeamPlayers(GetTeam());
		local maxDist = 0;
		local target = nil;
		for i = 1, #numPlayer
		do
			local dist = GetUnitToUnitDistance(GetTeamMember(i), bot);
			if dist > maxDist and dist < nCastRange and GetTeamMember(i):IsAlive() then
				maxDist = dist;
				target = GetTeamMember(i);
			end
		end
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
		local tableNearbyCreeps = bot:GetNearbyLaneCreeps( 1000, false );
		for _,creep in pairs(tableNearbyCreeps)
		do
			local dist = GetUnitToUnitDistance(creep, bot);
			if dist > maxDist and dist < nCastRange then
				maxDist = dist;
				target = creep;
			end
		end
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end

	-- If we're in a teamfight, use it on the protect ally
	if J.IsInTeamFight(bot, 1200)
	then
		local lowHpAlly = nil;
		local nLowestHealth = 1000;

		local tableNearbyAllies = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( J.CanCastOnNonMagicImmune( npcAlly ) )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.5 ) or J.IsDisabled(npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end
		if ( lowHpAlly ~= nil )
		then
			return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
		end
	end

	-- If we're going after someone
	if ( bot:GetActiveMode() == BOT_MODE_ATTACK or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = bot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, bot ) < 1000 ) 
		then
			local numPlayer =  GetTeamPlayers(GetTeam());
			local minDist = 10000;
			local target = nil;
			for i = 1, #numPlayer
			do
				local dist = GetUnitToUnitDistance(GetTeamMember(i), npcTarget);
				if dist < minDist and dist < nCastRange and GetTeamMember(i):IsAlive() then
					minDist = dist;
					target = GetTeamMember(i);
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROAM or
	   bot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
	   bot:GetActiveMode() == BOT_MODE_GANK 
	then
		local npcTarget = bot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, bot ) > 5000 ) 
		then
			local tableNearbyAllies = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE  );
			if tableNearbyAllies ~= nil and #tableNearbyAllies >= 1 and abilityRC:IsFullyCastable() then
				return BOT_ACTION_DESIRE_MODERATE, tableNearbyAllies[1];
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;
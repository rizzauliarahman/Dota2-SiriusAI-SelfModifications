-----------------
--英雄：军团指挥官
--技能：强攻
--键位：W
--类型：指向目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('legion_commander_press_the_attack')
local abilityR = bot:GetAbilityByName('legion_commander_duel')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 120 --魔法储量
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
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
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
	local nCastRangeU = abilityR:GetCastRange();
	local nCastRange = ability:GetCastRange();
	
	if bot:GetHealth() / bot:GetMaxHealth() < 0.5 and bot:GetMana() / bot:GetMaxMana() > 0.5 then
		return BOT_ACTION_DESIRE_LOW, bot;
	end
	
	if J.IsRetreating(bot)
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
	
	if bot:GetActiveMode() == BOT_MODE_FARM and bot:GetHealth() / bot:GetMaxHealth() < 0.55
	then
		return BOT_ACTION_DESIRE_LOW, bot;
	end	
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, 300)  )
		then
			return BOT_ACTION_DESIRE_LOW, bot;
		end
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(bot, 1200)
	then

		local lowHpAlly = nil;
		local nLowestHealth = 1000;

		local tableNearbyAllies = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if (  J.CanCastOnNonMagicImmune(npcAlly)  )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) or J.IsDisabled(npcAlly) )
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
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, 2*nCastRangeU)
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;
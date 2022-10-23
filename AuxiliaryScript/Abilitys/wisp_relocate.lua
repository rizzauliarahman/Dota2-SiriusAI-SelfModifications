-----------------
--英雄：艾欧
--技能：降临
--键位：R
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('wisp_relocate')
local abilityDC = bot:GetAbilityByName('wisp_tether')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 160 --魔法储量
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
    
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and bot:WasRecentlyDamagedByAnyHero(1.0) then
			local location = J.GetTeamFountain();
			return BOT_ACTION_DESIRE_MODERATE, location;
		end
	end
	
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
				if npcAlly:HasModifier('modifier_wisp_tether') and ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) or J.IsDisabled(npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end
		if ( lowHpAlly ~= nil and abilityDC:IsFullyCastable() )
		then
			local location = J.GetTeamFountain();
			return BOT_ACTION_DESIRE_MODERATE, location;
		end
	end

	if  J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, bot ) > 3000  ) 
		then
			local tableNearbyAllies = npcTarget:GetNearbyHeroes( 1300, true, BOT_MODE_NONE  );
			if tableNearbyAllies ~= nil and #tableNearbyAllies >= 2 and abilityDC:IsFullyCastable() then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end


return X;
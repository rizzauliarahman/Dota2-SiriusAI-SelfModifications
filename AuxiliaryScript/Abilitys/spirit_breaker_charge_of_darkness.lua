-----------------
--英雄：裂魂人
--技能：暗影冲刺
--键位：Q
--类型：指向目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('spirit_breaker_charge_of_darkness')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 300 --魔法储量
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
		bot:Action_ClearActions(true);
		bot.chargeTarget = castTarget;
		bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ); --使用技能
		bot:ActionQueue_Delay( 1.0 );
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
	local nCastRange = bot:GetAttackRange() + 150;
	
	if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS );
		for _,creep in pairs(enemyCreeps) 
		do
			if GetUnitToUnitDistance(creep, bot) > 2500 and J.CanCastOnNonMagicImmune(creep) then
				return BOT_ACTION_DESIRE_MODERATE, creep;
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and
			not J.IsDisabled(npcTarget) ) 
		then
			local Ally = npcTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			local Enemy = npcTarget:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
			if ( #Ally + 1 >= #Enemy  ) or npcTarget:GetHealth() <= ( 100 + (5*bot:GetLevel()) ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end	
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

return X;
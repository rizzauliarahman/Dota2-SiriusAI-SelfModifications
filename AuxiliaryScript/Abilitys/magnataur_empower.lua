-----------------
--英雄：马格纳斯
--技能：授予力量
--键位：W
--类型：指向单位
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('magnataur_empower')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 180 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

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

    local nCastRange = ability:GetCastRange();
	if nCastRange > 1600 then nCastRange = 1600; end
	-- If we're pushing or defending a lane
	if J.IsDefending(bot) or J.IsPushing(bot)
	then
		if not bot:HasModifier("modifier_magnataur_empower") then
			return BOT_ACTION_DESIRE_MODERATE, bot;
		end
		local tableNearbyFriendlyHeroes = bot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( not myFriend:HasModifier("modifier_magnataur_empower") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, bot;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		if not bot:HasModifier("modifier_magnataur_empower") then
			return BOT_ACTION_DESIRE_MODERATE, bot;
		end
		local tableNearbyFriendlyHeroes = bot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( not myFriend:HasModifier("modifier_magnataur_empower") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
	end
	
	return 0;
end

return X;
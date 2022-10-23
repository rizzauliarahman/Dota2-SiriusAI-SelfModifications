-----------------
--英雄：艾欧
--技能：断开连接
--键位：D
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('wisp_spirits_in')
local abilitySP = bot:GetAbilityByName('wisp_spirits')

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
    X.Compensation() 
    if bot.spiritState == 0 then
        bot.spiritState = 1
    else
        bot.spiritState = 0
    end
    bot:ActionQueue_UseAbility( ability ) --使用技能
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
       or ability:IsHidden()
       or not bot:HasModifier("modifier_wisp_spirits")
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

    if bot.spiritState == 0 then
        local nMinRange = abilitySP:GetSpecialValueInt("min_range");
	    local nMaxRange = abilitySP:GetSpecialValueInt("max_range");
	    local nRadius = abilitySP:GetSpecialValueInt("radius");
        
	    if  J.IsGoingOnSomeone(bot)
	    then
	    	local npcTarget = bot:GetTarget();
	    	if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, bot ) < nMaxRange /2 )
	    	then
	    		return BOT_ACTION_DESIRE_MODERATE
	    	end
	    end
    else
        local nMinRange = abilitySP:GetSpecialValueInt("min_range");
        local nMaxRange = abilitySP:GetSpecialValueInt("max_range");
        local nRadius = abilitySP:GetSpecialValueInt("radius");
        
        if  J.IsGoingOnSomeone(bot)
        then
            local npcTarget = bot:GetTarget();
            if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, bot ) >= nMaxRange/2  ) 
            then
                return BOT_ACTION_DESIRE_MODERATE
            end
        end
    end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;